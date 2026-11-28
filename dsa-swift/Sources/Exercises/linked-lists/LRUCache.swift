// Problem: LRU cache (M25 · LRU cache)

public enum LRUCache {
    /// Holds at most `capacity` entries. Adding a new key to a full cache first throws out the least
    /// recently used entry. Reading or setting a key counts as using it.
    ///
    /// Aim for O(1) `value(for:)` and `setValue(_:for:)`: a dictionary from keys to the nodes of a doubly
    /// linked list kept in order of use.
    public final class Cache<Key: Hashable, Value> {
        /// The most entries the cache holds. At least 1.
        public let capacity: Int

        public init(capacity: Int) {
            self.capacity = capacity
        }

        /// The number of entries.
        public var count: Int {
            // Write your solution here, then run:
            // swift test --filter LRUCacheTests
            return 0
        }

        /// The value for `key`, or nil if it isn't cached. Finding it makes `key` the most recently used.
        public func value(for key: Key) -> Value? {
            return nil
        }

        /// Stores `value` for `key`, replacing any old value, and makes `key` the most recently used.
        /// If that takes the cache over capacity, removes the least recently used entry.
        public func setValue(_ value: Value, for key: Key) {
        }

        /// Removes `key` and returns its value, or returns nil if it isn't cached.
        @discardableResult
        public func removeValue(for key: Key) -> Value? {
            return nil
        }

        /// Every cached key, most recently used first.
        public var keysByRecency: [Key] {
            return []
        }
    }
}
