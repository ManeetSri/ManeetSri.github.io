// Problem: An insertion-ordered dictionary with fast removal (M64 · TreeSet, TreeDictionary, OrderedSet and OrderedDictionary)

public enum InsertionOrderedMap {
    /// A dictionary that remembers the order keys were first added, with amortised O(1) lookups,
    /// insertions, updates, removals and popFirst(). No access by position.
    public struct Map<Key: Hashable, Value> {
        // Write your solution here, then run:
        // swift test --filter InsertionOrderedMapTests
        // Add whatever private storage you need: slots in order, a dictionary from key to slot, a head.

        /// Creates an empty map.
        public init() {}

        /// How many keys the map holds.
        public var count: Int {
            return 0
        }

        /// The value for `key`, or nil. Setting a new key adds it at the end; setting an existing key
        /// changes its value in place; setting nil removes the key.
        public subscript(key: Key) -> Value? {
            get {
                return nil
            }
            set {
            }
        }

        /// Removes `key` and returns its value, or returns nil if it isn't there.
        @discardableResult
        public mutating func removeValue(forKey key: Key) -> Value? {
            return nil
        }

        /// Removes and returns the oldest entry, or nil if the map is empty.
        public mutating func popFirst() -> (key: Key, value: Value)? {
            return nil
        }

        /// The keys, oldest first.
        public var keys: [Key] {
            return []
        }

        /// The values, in the same order as `keys`.
        public var values: [Value] {
            return []
        }
    }
}
