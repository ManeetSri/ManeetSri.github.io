// Problem: LFU cache (M64 · LFU cache)

public enum LFUCache {
    /// Holds at most `capacity` entries. Every entry has a use count: setting a new key gives it 1, and
    /// reading it or setting it again adds 1. Adding a new key to a full cache first evicts the entry
    /// with the lowest count; among entries with that count, the least recently used one goes.
    ///
    /// Aim for O(1) `value(for:)` and `setValue(_:for:)`: a dictionary from keys to nodes, and one doubly
    /// linked list of nodes per count, most recently used first.
    public final class Cache<Key: Hashable, Value> {
        /// The most entries the cache holds. A capacity of 0 stores nothing.
        public let capacity: Int

        public init(capacity: Int) {
            self.capacity = capacity
        }

        /// The number of entries.
        public var count: Int {
            // Write your solution here, then run:
            // swift test --filter LFUCacheTests
            return 0
        }

        /// The value for `key`, or nil if it isn't cached. Finding it adds 1 to the key's count.
        public func value(for key: Key) -> Value? {
            return nil
        }

        /// Stores `value` for `key`. An existing key keeps its place and its count goes up by 1; a new key
        /// starts with a count of 1, after evicting an entry if the cache is full.
        public func setValue(_ value: Value, for key: Key) {
        }

        /// The key's use count, or 0 if it isn't cached. Asking doesn't count as a use.
        public func frequency(of key: Key) -> Int {
            return 0
        }

        /// Every cached key in the order they would be evicted: lowest count first, and within a count,
        /// least recently used first.
        public var evictionOrder: [Key] {
            return []
        }
    }
}
