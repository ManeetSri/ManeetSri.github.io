// Problem: Skip list from scratch (M64 · Skip lists)

public enum SkipListFromScratch {
    /// A sorted set of distinct Ints stored as a skip list. A new node's height comes from `coinFlip`:
    /// start at 1 and add a level for every `true`, stopping at the first `false` or at `maxLevel`.
    /// Only inserting a value that isn't already present flips the coin.
    ///
    /// Aim for O(log n) expected `insert`, `remove`, `contains` and `ceiling`.
    public final class SkipSet {
        /// The tallest a node can be. At least 1.
        public let maxLevel: Int

        public init(maxLevel: Int = 16, coinFlip: @escaping () -> Bool) {
            self.maxLevel = maxLevel
            // Write your solution here, then run:
            // swift test --filter SkipListFromScratchTests
        }

        /// The number of values.
        public var count: Int {
            return 0
        }

        /// True if `value` is in the set.
        public func contains(_ value: Int) -> Bool {
            return false
        }

        /// The smallest value in the set that is ≥ `value`, or nil if there isn't one.
        public func ceiling(_ value: Int) -> Int? {
            return nil
        }

        /// Adds `value`. Returns false, and changes nothing, if it was already there.
        @discardableResult
        public func insert(_ value: Int) -> Bool {
            return false
        }

        /// Removes `value`. Returns false if it wasn't there.
        @discardableResult
        public func remove(_ value: Int) -> Bool {
            return false
        }

        /// Every value, in increasing order.
        public var elements: [Int] {
            return []
        }

        /// How many nodes are on each level, from level 1 up to the highest level that has any node.
        /// Empty when the set is empty.
        public var levelSizes: [Int] {
            return []
        }
    }
}
