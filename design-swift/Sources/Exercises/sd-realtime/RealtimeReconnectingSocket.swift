// Kata: A reconnecting socket client (D35 · Reconnection, heartbeats and backoff)
import DesignKit

public enum RealtimeReconnectingSocket {
    /// What travels over the connection, already decoded. In the app these are WebSocket messages.
    public enum Frame: Equatable, Sendable {
        case subscribe(String)
        case unsubscribe(String)
        case ping
        case pong
        case event(topic: String, body: String)
    }

    /// One open connection. `receive()` waits for the next frame and throws once the connection has dropped
    /// or been closed. Like `URLSessionWebSocketTask.receive()`, it does **not** return when its task is
    /// cancelled: `close()` is what ends a pending receive.
    public protocol Connection: Sendable {
        func send(_ frame: Frame) async throws
        func receive() async throws -> Frame
        func close() async
    }

    /// Opens connections: a WebSocket in the app, a fake in tests. `connect()` throws if it can't.
    public protocol Transport: Sendable {
        func connect() async throws -> any Connection
    }

    public struct Policy: Sendable {
        /// The wait before the first retry in a row; each retry after that waits twice as long
        public var base: Duration
        /// No wait is longer than this
        public var cap: Duration
        /// How long a connection runs between heartbeats
        public var pingInterval: Duration
        /// How long to wait, after a ping, for any frame to prove the connection is alive
        public var pongTimeout: Duration
        /// Applied to every backoff delay. Production code passes full jitter; tests pass a fixed rule.
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
    }

    public enum State: Equatable, Sendable {
        /// Created, not started
        case idle
        /// Waiting for `connect()`
        case connecting
        /// A connection is open
        case connected
        /// Waiting `delay` before reconnecting. `retry` counts failures in a row, from 0.
        case waiting(retry: Int, delay: Duration)
        /// Stopped for good
        case stopped
    }

    public actor Client {
        private let transport: any Transport
        private let clock: any Clock<Duration>
        private let policy: Policy
        private let onEvent: @Sendable (_ topic: String, _ body: String) -> Void

        /// Where the client is in its life
        public private(set) var state: State = .idle

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

        /// Connects, and keeps reconnecting until `stop()`. Calling it again does nothing.
        public func start() {
            // Write your solution here, then run:
            // swift test --filter RealtimeReconnectingSocketTests
        }

        /// Closes the connection and never reconnects
        public func stop() async {
        }

        /// Adds a topic. Sent at once if connected, and again after every reconnect.
        public func subscribe(_ topic: String) async {
        }

        /// Removes a topic. Sent at once if connected; not sent after reconnects.
        public func unsubscribe(_ topic: String) async {
        }
    }
}
