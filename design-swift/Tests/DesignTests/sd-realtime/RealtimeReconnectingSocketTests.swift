import DesignKit
import Synchronization
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Socket = RealtimeReconnectingSocket

/// One fake connection. The test delivers frames or drops it; it records what the client sends. Like a real
/// WebSocket, a pending receive only ends when a frame arrives or the connection closes or drops.
private final class FakeSocketConnection: RealtimeReconnectingSocket.Connection {
    struct Dropped: Error {}

    private struct State {
        var inbox: [Socket.Frame] = []
        var waiter: CheckedContinuation<Socket.Frame, any Error>?
        var sent: [Socket.Frame] = []
        var closedByClient = false
        var dropped = false
    }

    private let state = Mutex(State())

    var sent: [Socket.Frame] { state.withLock { $0.sent } }
    var pings: Int { sent.filter { $0 == .ping }.count }
    var isClosed: Bool { state.withLock { $0.closedByClient } }
    /// True while the client is waiting in `receive()`: after a delivery, the frame has been handled once it's back
    var isReceiving: Bool { state.withLock { $0.waiter != nil } }

    func send(_ frame: Socket.Frame) async throws {
        let ok = state.withLock { state in
            guard !state.closedByClient, !state.dropped else { return false }
            state.sent.append(frame)
            return true
        }
        if !ok { throw Dropped() }
    }

    func receive() async throws -> Socket.Frame {
        try await withCheckedThrowingContinuation { continuation in
            let ready = state.withLock { state -> Result<Socket.Frame, any Error>? in
                if !state.inbox.isEmpty { return .success(state.inbox.removeFirst()) }
                if state.closedByClient || state.dropped { return .failure(Dropped()) }
                state.waiter = continuation
                return nil
            }
            if let ready { continuation.resume(with: ready) }
        }
    }

    func close() async {
        end { $0.closedByClient = true }
    }

    /// The server sends a frame
    func deliver(_ frame: Socket.Frame) {
        let waiter = state.withLock { state -> CheckedContinuation<Socket.Frame, any Error>? in
            guard let waiter = state.waiter else {
                state.inbox.append(frame)
                return nil
            }
            state.waiter = nil
            return waiter
        }
        waiter?.resume(returning: frame)
    }

    /// The network loses the connection
    func drop() {
        end { $0.dropped = true }
    }

    private func end(_ mark: @Sendable (inout State) -> Void) {
        let waiter = state.withLock { state -> CheckedContinuation<Socket.Frame, any Error>? in
            mark(&state)
            let waiter = state.waiter
            state.waiter = nil
            return waiter
        }
        waiter?.resume(throwing: Dropped())
    }
}

/// A scripted network: each connect takes the next outcome from the script, and accepts once it runs out
private final class FakeSocketNetwork: RealtimeReconnectingSocket.Transport {
    enum Outcome: Sendable { case refuse, accept }
    struct Refused: Error {}

    private struct State {
        var script: [Outcome]
        var attempts = 0
        var connections: [FakeSocketConnection] = []
    }

    private let state: Mutex<State>

    init(_ script: [Outcome] = []) {
        state = Mutex(State(script: script))
    }

    var attempts: Int { state.withLock { $0.attempts } }

    /// The nth connection that opened, from 1
    func connection(_ number: Int) -> FakeSocketConnection? {
        state.withLock { $0.connections.indices.contains(number - 1) ? $0.connections[number - 1] : nil }
    }

    func connect() async throws -> any RealtimeReconnectingSocket.Connection {
        let opened = state.withLock { state -> FakeSocketConnection? in
            state.attempts += 1
            if !state.script.isEmpty, state.script.removeFirst() == .refuse { return nil }
            let connection = FakeSocketConnection()
            state.connections.append(connection)
            return connection
        }
        guard let opened else { throw Refused() }
        return opened
    }
}

private final class EventLog: Sendable {
    private let lines = Mutex<[String]>([])
    var all: [String] { lines.withLock { $0 } }
    func append(_ line: String) { lines.withLock { $0.append(line) } }
}

@Suite struct RealtimeReconnectingSocketTests {
    private struct Harness {
        let network: FakeSocketNetwork
        let clock = TestClock()
        let events = EventLog()
        let client: Socket.Client

        init(_ script: [FakeSocketNetwork.Outcome] = [], policy: Socket.Policy = Socket.Policy(base: .seconds(1), cap: .seconds(4))) {
            network = FakeSocketNetwork(script)
            let events = events
            client = Socket.Client(transport: network, clock: clock, policy: policy) { topic, body in
                events.append("\(topic): \(body)")
            }
        }

        /// Yields until the condition holds; gives up after a while, so a wrong answer fails instead of hanging
        @discardableResult
        func until(_ condition: () async -> Bool) async -> Bool {
            for _ in 0..<20_000 {
                if await condition() { return true }
                await Task.yield()
            }
            return await condition()
        }

        /// Waits until the client is in `state` and waiting on the clock (for a heartbeat or a backoff)
        func reach(_ state: Socket.State) async -> Bool {
            await until { await client.state == state && clock.sleeperCount == 1 }
        }

        /// Delivers a frame and waits until the client has read it and is listening again
        func deliver(_ frame: Socket.Frame, on connection: FakeSocketConnection) async {
            connection.deliver(frame)
            await until { connection.isReceiving }
        }
    }

    @Test("Start connects and subscribes to every topic, in the order they were added")
    func connectsAndSubscribes() async throws {
        let harness = Harness()
        await harness.client.subscribe("match:1")
        await harness.client.subscribe("match:2")
        await harness.client.subscribe("match:1")
        await harness.client.start()
        await harness.client.start()

        #expect(await harness.reach(.connected))
        let first = try #require(harness.network.connection(1))
        await harness.until { first.sent.count >= 2 }
        #expect(first.sent == [.subscribe("match:1"), .subscribe("match:2")])
        #expect(harness.network.attempts == 1)
    }

    @Test("While connected, subscribe and unsubscribe are sent at once, and a reconnect resends what's left")
    func resubscribesAfterReconnect() async throws {
        let harness = Harness()
        await harness.client.start()
        #expect(await harness.reach(.connected))
        let first = try #require(harness.network.connection(1))

        await harness.client.subscribe("match:1")
        await harness.client.subscribe("match:2")
        await harness.client.unsubscribe("match:2")
        await harness.client.unsubscribe("match:9")
        await harness.until { first.sent.count >= 3 }
        #expect(first.sent == [.subscribe("match:1"), .subscribe("match:2"), .unsubscribe("match:2")])

        first.drop()
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))
        harness.clock.advance(by: .seconds(1))
        #expect(await harness.reach(.connected))
        let second = try #require(harness.network.connection(2))
        await harness.until { !second.sent.isEmpty }
        #expect(second.sent == [.subscribe("match:1")])
    }

    @Test("Failed connections wait base, then twice as long each time, up to the cap")
    func exponentialBackoff() async {
        let harness = Harness([.refuse, .refuse, .refuse, .refuse])
        await harness.client.start()
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))

        harness.clock.advance(by: .milliseconds(999))
        await settle()
        #expect(harness.network.attempts == 1)

        harness.clock.advance(by: .milliseconds(1))
        #expect(await harness.reach(.waiting(retry: 1, delay: .seconds(2))))
        #expect(harness.network.attempts == 2)

        harness.clock.advance(by: .seconds(2))
        #expect(await harness.reach(.waiting(retry: 2, delay: .seconds(4))))

        harness.clock.advance(by: .seconds(4))
        #expect(await harness.reach(.waiting(retry: 3, delay: .seconds(4))))

        harness.clock.advance(by: .seconds(4))
        #expect(await harness.reach(.connected))
        #expect(harness.network.attempts == 5)
    }

    @Test("The backoff only starts again after a connection has delivered a frame")
    func backoffResetsAfterHealthyConnection() async throws {
        let harness = Harness([.refuse])
        await harness.client.start()
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))
        harness.clock.advance(by: .seconds(1))
        #expect(await harness.reach(.connected))

        // It opened, then died before saying anything: that's another failure in the same row
        let first = try #require(harness.network.connection(1))
        first.drop()
        #expect(await harness.reach(.waiting(retry: 1, delay: .seconds(2))))
        harness.clock.advance(by: .seconds(2))
        #expect(await harness.reach(.connected))

        // This one proved itself, so the next drop starts a fresh row
        let second = try #require(harness.network.connection(2))
        await harness.deliver(.event(topic: "match:1", body: "1-0"), on: second)
        second.drop()
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))
    }

    @Test("A ping every interval; an answered ping keeps the connection, a silent one replaces it")
    func heartbeat() async throws {
        let harness = Harness(policy: Socket.Policy(base: .seconds(1), cap: .seconds(4), pingInterval: .seconds(25), pongTimeout: .seconds(10)))
        await harness.client.start()
        #expect(await harness.reach(.connected))
        let first = try #require(harness.network.connection(1))

        harness.clock.advance(by: .seconds(24))
        await settle()
        #expect(first.pings == 0)
        harness.clock.advance(by: .seconds(1))
        #expect(await harness.until { first.pings == 1 && harness.clock.sleeperCount == 1 })

        await harness.deliver(.pong, on: first)
        harness.clock.advance(by: .seconds(10))
        #expect(await harness.reach(.connected))
        #expect(!first.isClosed)

        harness.clock.advance(by: .seconds(25))
        #expect(await harness.until { first.pings == 2 && harness.clock.sleeperCount == 1 })
        harness.clock.advance(by: .seconds(9))
        await settle()
        #expect(!first.isClosed)

        harness.clock.advance(by: .seconds(1))
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))
        #expect(first.isClosed)
        harness.clock.advance(by: .seconds(1))
        #expect(await harness.reach(.connected))
        #expect(harness.network.attempts == 2)
    }

    @Test("Events reach the app from every connection")
    func deliversEvents() async throws {
        let harness = Harness()
        await harness.client.start()
        #expect(await harness.reach(.connected))
        let first = try #require(harness.network.connection(1))
        await harness.deliver(.event(topic: "match:1", body: "1-0"), on: first)
        first.drop()

        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))
        harness.clock.advance(by: .seconds(1))
        #expect(await harness.reach(.connected))
        let second = try #require(harness.network.connection(2))
        await harness.deliver(.event(topic: "match:1", body: "2-0"), on: second)
        #expect(harness.events.all == ["match:1: 1-0", "match:1: 2-0"])
    }

    @Test("Stop closes the open connection, and nothing reconnects afterwards")
    func stopWhileConnected() async throws {
        let harness = Harness()
        await harness.client.start()
        #expect(await harness.reach(.connected))
        let first = try #require(harness.network.connection(1))

        await harness.client.stop()
        #expect(await harness.until { first.isClosed })
        #expect(await harness.client.state == .stopped)

        await harness.client.start()
        harness.clock.advance(by: .seconds(120))
        await settle()
        #expect(harness.network.attempts == 1)
        #expect(await harness.client.state == .stopped)
    }

    @Test("Stopping during a backoff cancels the reconnect")
    func stopWhileWaiting() async {
        let harness = Harness([.refuse])
        await harness.client.start()
        #expect(await harness.reach(.waiting(retry: 0, delay: .seconds(1))))

        await harness.client.stop()
        #expect(await harness.client.state == .stopped)
        #expect(await harness.until { harness.clock.sleeperCount == 0 })
        harness.clock.advance(by: .seconds(10))
        await settle()
        #expect(harness.network.attempts == 1)
    }

    @Test("Every backoff delay goes through the jitter rule it's given")
    func appliesJitter() async {
        let harness = Harness([.refuse, .refuse], policy: Socket.Policy(base: .seconds(1), cap: .seconds(4), jitter: { $0 / 2 }))
        await harness.client.start()
        #expect(await harness.reach(.waiting(retry: 0, delay: .milliseconds(500))))
        harness.clock.advance(by: .milliseconds(500))
        #expect(await harness.reach(.waiting(retry: 1, delay: .seconds(1))))
    }
}
