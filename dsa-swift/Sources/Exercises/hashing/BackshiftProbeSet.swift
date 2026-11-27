// Problem: A probing set without tombstones (M24 · Inside Swift's Dictionary)

public enum BackshiftProbeSet {
    /// A set of Ints stored like Swift's Set: one array of slots, linear probing from home slot
    /// `key & (capacity - 1)`, doubling before it would pass three quarters full, and backward-shift
    /// deletion instead of tombstones.
    public struct ProbeSet {
        // Write your solution here, then run:
        // swift test --filter BackshiftProbeSetTests
        // Add whatever private storage you need.

        /// An empty table of `capacity` slots, a power of two.
        public init(capacity: Int) {}

        /// How many keys the set holds.
        public var count: Int {
            return 0
        }

        /// How many slots the table has.
        public var capacity: Int {
            return 0
        }

        /// The table as it is now: a key, or nil for an empty slot.
        public var slots: [Int?] {
            return []
        }

        /// Adds `key`, growing first if needed. Returns false if it was already there.
        @discardableResult
        public mutating func insert(_ key: Int) -> Bool {
            return false
        }

        /// True if `key` is in the set.
        public func contains(_ key: Int) -> Bool {
            return false
        }

        /// Removes `key` with a backward shift. Returns false if it wasn't there.
        @discardableResult
        public mutating func remove(_ key: Int) -> Bool {
            return false
        }
    }
}
