// Reference solution: Single-flight request group. The in-flight Task is stored before the first
// suspension point, so a caller that arrives while the actor is waiting finds it and joins. The work runs
// in its own unstructured Task, which is what keeps one caller's cancellation from reaching the others.

public enum ResilienceSingleFlight {
    public actor Group<Key: Hashable & Sendable, Value: Sendable> {
        private var running: [Key: Task<Value, any Error>] = [:]

        public init() {}

        public var inFlight: Int {
            running.count
        }

        public func run(_ key: Key, _ work: @escaping @Sendable () async throws -> Value) async throws -> Value {
            if let existing = running[key] {
                return try await existing.value
            }
            let task = Task { try await work() }
            running[key] = task
            do {
                let value = try await task.value
                forget(task, for: key)
                return value
            } catch {
                // Forget failures too, or every later call would get this error without trying again
                forget(task, for: key)
                throw error
            }
        }

        /// Removes the entry only if it's still this run's: a newer run for the key must stay
        private func forget(_ task: Task<Value, any Error>, for key: Key) {
            if running[key] == task {
                running[key] = nil
            }
        }
    }
}
