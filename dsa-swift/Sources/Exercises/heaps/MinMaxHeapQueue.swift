// Problem: A queue that's fast at both ends (M39 · swift-collections Heap)

public enum MinMaxHeapQueue {
    /// A double-ended priority queue of Ints, named like swift-collections' Heap: O(1) `min` and `max`,
    /// O(log n) `insert`, `popMin()` and `popMax()`. Build it as a min-max heap in an array.
    public struct BothEndsQueue {
        // Write your solution here, then run:
        // swift test --filter MinMaxHeapQueueTests
        // Add the private storage you need: an array is all a min-max heap needs.

        public init() {}

        /// How many values are queued.
        public var count: Int {
            return 0
        }

        /// True when nothing is queued.
        public var isEmpty: Bool {
            return true
        }

        /// The smallest value, or nil when empty. O(1).
        public var min: Int? {
            return nil
        }

        /// The largest value, or nil when empty. O(1).
        public var max: Int? {
            return nil
        }

        /// Adds `value`. O(log n).
        public mutating func insert(_ value: Int) {
        }

        /// Removes and returns the smallest value, or nil when empty. O(log n).
        public mutating func popMin() -> Int? {
            return nil
        }

        /// Removes and returns the largest value, or nil when empty. O(log n).
        public mutating func popMax() -> Int? {
            return nil
        }
    }
}
