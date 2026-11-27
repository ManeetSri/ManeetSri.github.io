// Problem: Expiring key-value store (M72 · Key-value store with TTL)

public enum ExpiringKeyValueStore {
    /// A key-value store whose entries expire. Every call passes in the current time, `now`, which
    /// never goes backwards from one call to the next.
    public struct Store<Key: Hashable, Value> {
        // Write your solution here, then run:
        // swift test --filter ExpiringKeyValueStoreTests
        // Add whatever private storage you need. You may `import DSAKit` and use its Heap.

        /// Creates an empty store.
        public init() {
        }

        /// Stores `value` for `key`, replacing any earlier value. It lives for `ttl` time units (at
        /// least 1): it can be read at times before `now + ttl` and is gone from `now + ttl` on.
        public mutating func set(_ value: Value, for key: Key, ttl: Int, now: Int) {
        }

        /// The live value for `key`, or nil if it was never set, was removed or has expired.
        public mutating func value(for key: Key, now: Int) -> Value? {
            return nil
        }

        /// Removes the entry for `key` and returns its value if it was still live, otherwise nil.
        @discardableResult
        public mutating func removeValue(for key: Key, now: Int) -> Value? {
            return nil
        }

        /// How many entries are live at `now`.
        public mutating func count(now: Int) -> Int {
            return 0
        }
    }
}
