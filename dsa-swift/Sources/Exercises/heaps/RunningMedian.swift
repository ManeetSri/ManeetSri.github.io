// Problem: Median of a stream (M39 · Two heaps: median of a stream)

import DSAKit

public enum RunningMedian {
    /// Collects numbers one at a time and reports the median of everything added so far.
    public struct MedianTracker {
        // Write your solution here, then run:
        // swift test --filter RunningMedianTests
        // Add the private storage you need. DSAKit's Heap is imported, if you want it.

        /// Creates an empty tracker.
        public init() {}

        /// How many numbers have been added.
        public var count: Int {
            return 0
        }

        /// Adds `value`. Aim for O(log n).
        public mutating func add(_ value: Int) {
        }

        /// The middle value for an odd count, the mean of the two middle values for an even count, or
        /// nil before anything has been added. Aim for O(1).
        public var median: Double? {
            return nil
        }
    }
}
