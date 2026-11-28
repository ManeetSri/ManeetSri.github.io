// Reference solution: A reconnecting socket client. One task owns the connection's whole life: connect,
// resubscribe, then race a receive loop against a heartbeat until one of them says the connection is
// over, then back off and go round again. Closing the connection is what ends a pending receive.
import DesignKit

public enum RealtimeReconnectingSocket {
    public enum Frame: Equatable, Sendable {
        case subscribe(String)
        case unsubscribe(String)
        case ping
        case pong
        case event(topic: String, body: String)
    }

    public protocol Connection: Sendable {
        func send(_ frame: Frame) async throws
        func receive() async throws -> Frame
        func close() async
    }

    public protocol Transport: Sendable {
        func connect() async throws -> any Connection
    }

    public struct Policy: Sendable {
        public var base: Duration
        public var cap: Duration
        public var pingInterval: Duration
        public var pongTimeout: Duration
        public var jitter: @Sendable (Duration) -> Duration

        public init(
            base: Duration = .seconds(1),
            cap: Duration = .seconds(30),
            pingInterval: Duration = .seconds(25),
            pongTimeout: Duration = .seconds(10),
            jitter: @escaping @Sendable (Duration) -> Duration = { $0 }
        ) {
            self.base = base
            self.cap = cap
            self.pingInterval = pingInterval
            self.pongTimeout = pongTimeout
            self.jitter = jitter
        }

        /// Capped exponential backoff for the retry-th failure in a row (from 0), then jitter
        func delay(retry: Int) -> Duration {
            jitter(min(cap, base * (1 << min(retry, 30))))
        }
    }

    public enum State: Equatable, Sendable {
        case idle
        case connecting
        case connected
        case waiting(retry: Int, delay: Duration)
        case stopped
    }

    public actor Client {
        private let transport: any Transport
        private let clock: any Clock<Duration>
        private let policy: Policy
        private let onEvent: @Sendable (_ topic: String, _ body: String) -> Void

        public private(set) var state: State = .idle
        private var topics: [String] = []
        private var connection: (any Connection)?
        private var runner: Task<Void, Never>?
        /// Frames heard on the current connection: the heartbeat compares it before and after a ping
        private var framesHeard = 0

        public init(
            transport: any Transport,
            clock: any Clock<Duration>,
            policy: Policy = Policy(),
            onEvent: @escaping @Sendable (_ topic: String, _ body: String) -> Void = { _, _ in }
        ) {
            self.transport = transport
            self.clock = clock
            self.policy = policy
            self.onEvent = onEvent
        }

        public func start() {
            guard state == .idle else { return }
            state = .connecting
            runner = Task { await self.run() }
        }

        public func stop() async {
            guard state != .stopped else { return }
            state = .stopped
            runner?.cancel()
            runner = nil
            // A pending receive ignores cancellation, as URLSessionWebSocketTask's does: closing ends it
            if let open = connection {
                connection = nil
                await open.close()
            }
        }

        public func subscribe(_ topic: String) async {
            guard !topics.contains(topic) else { return }
            topics.append(topic)
            if state == .connected, let connection {
                try? await connection.send(.subscribe(topic))
            }
        }

        public func unsubscribe(_ topic: String) async {
            guard let index = topics.firstIndex(of: topic) else { return }
            topics.remove(at: index)
            if state == .connected, let connection {
                try? await connection.send(.unsubscribe(topic))
            }
        }

        private func run() async {
            var retry = 0
            while !Task.isCancelled {
                state = .connecting
                var healthy = false
                if let opened = try? await transport.connect() {
                    if Task.isCancelled {
                        await opened.close()
                        return
                    }
                    connection = opened
                    framesHeard = 0
                    state = .connected
                    for topic in topics {
                        try? await opened.send(.subscribe(topic))
                    }
                    healthy = await serve(opened)
                    connection = nil
                    await opened.close()
                }
                if Task.isCancelled { return }
                // A connection that delivered something was healthy: the next failure starts a fresh row
                if healthy { retry = 0 }
                let delay = policy.delay(retry: retry)
                state = .waiting(retry: retry, delay: delay)
                do {
                    try await clock.sleep(for: delay)
                } catch {
                    return
                }
                retry += 1
            }
        }

        /// Runs until the connection drops or stops answering; returns whether it delivered any frame
        private func serve(_ connection: any Connection) async -> Bool {
            await withTaskGroup(of: Bool.self) { group in
                group.addTask { await self.receiveLoop(connection) }
                group.addTask { await self.heartbeat(connection) }
                var healthy = false
                // Whichever finishes first ends the connection; the other follows once it's closed or cancelled
                if let first = await group.next() { healthy = healthy || first }
                group.cancelAll()
                await connection.close()
                for await result in group { healthy = healthy || result }
                return healthy
            }
        }

        private func receiveLoop(_ connection: any Connection) async -> Bool {
            var heardAny = false
            while let frame = try? await connection.receive() {
                heardAny = true
                framesHeard += 1
                if case let .event(topic, body) = frame {
                    onEvent(topic, body)
                }
            }
            return heardAny
        }

        /// Wait, ping, wait for any frame; a quiet connection is dead even if TCP hasn't noticed
        private func heartbeat(_ connection: any Connection) async -> Bool {
            do {
                while true {
                    try await clock.sleep(for: policy.pingInterval)
                    let before = framesHeard
                    try await connection.send(.ping)
                    try await clock.sleep(for: policy.pongTimeout)
                    if framesHeard == before { break }
                }
            } catch {}
            return false
        }
    }
}
