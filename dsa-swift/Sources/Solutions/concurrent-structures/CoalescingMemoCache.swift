// Reference solution: A coalescing memo cache. The actor keeps finished values in one dictionary and
// running computations, as Tasks, in another. value(for:compute:) checks both and, on a miss, creates
// the Task and records it before its first await: actor code between awaits runs without
// interruption, so no other request can slip in between the check and the record. Later requests for
// the same key find the Task and await its value, which is why compute runs once per key even with
// many concurrent callers. When the Task finishes, the first caller moves its value into the stored
// dictionary. Each operation is O(1) on average, apart from waiting for the computation.

public enum CoalescingMemoCache {
    public actor Store<Key: Hashable & Sendable, Value: Sendable> {
        private var stored: [Key: Value] = [:]
        private var running: [Key: Task<Value, Never>] = [:]

        public init() {}

        public func value(for key: Key, compute: @escaping @Sendable (Key) async -> Value) async -> Value {
            if let value = stored[key] {
                return value
            }
            if let task = running[key] {
                return await task.value                 // someone else is computing it: wait for theirs
            }
            let task = Task { await compute(key) }      // runs off the actor, so other requests can proceed
            running[key] = task                         // recorded before the first await
            let value = await task.value
            // Across that await, other requests may have run, but they only read `running`
            stored[key] = value
            running[key] = nil
            return value
        }

        public var storedCount: Int {
            stored.count
        }

        public func forget(_ key: Key) {
            stored[key] = nil
        }
    }
}
