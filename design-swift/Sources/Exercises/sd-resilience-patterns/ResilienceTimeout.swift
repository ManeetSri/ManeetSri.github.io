// Kata: Timeout with cancellation (D14 · Timeouts, deadlines and cancellation propagation)
import DesignKit

public enum ResilienceTimeout {
    /// Thrown when the operation didn't finish within its limit
    public struct TimedOut: Error, Equatable, Sendable {
        public let limit: Duration

        public init(limit: Duration) {
            self.limit = limit
        }
    }

    /// Runs `operation` and returns its result, unless `limit` passes first on `clock`: then the operation
    /// is cancelled and this throws `TimedOut`. The operation's own errors come through unchanged, and if
    /// the caller is cancelled the operation is cancelled too and this throws `CancellationError`.
    /// No timer is left waiting once it returns.
    public static func run<Value: Sendable>(within limit: Duration, clock: some Clock<Duration>, _ operation: @escaping @Sendable () async throws -> Value) async throws -> Value {
        // Write your solution here, then run:
        // swift test --filter ResilienceTimeoutTests
        throw Unimplemented()
    }
}
