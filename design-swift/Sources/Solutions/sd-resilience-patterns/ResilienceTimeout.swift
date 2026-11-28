// Reference solution: Timeout with cancellation. The operation and a timer race as two child tasks; the
// first to finish decides the result, and cancelling the group stops the loser. A task group always
// waits for its children, so this returns once the operation has actually stopped, not merely been told to.

public enum ResilienceTimeout {
    public struct TimedOut: Error, Equatable, Sendable {
        public let limit: Duration

        public init(limit: Duration) {
            self.limit = limit
        }
    }

    public static func run<Value: Sendable>(within limit: Duration, clock: some Clock<Duration>, _ operation: @escaping @Sendable () async throws -> Value) async throws -> Value {
        try await withThrowingTaskGroup(of: Value.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await clock.sleep(for: limit)
                throw TimedOut(limit: limit)
            }
            defer { group.cancelAll() }
            guard let first = try await group.next() else { throw CancellationError() }
            return first
        }
    }
}
