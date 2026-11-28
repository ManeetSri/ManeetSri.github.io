// Reference solution: Median of a stream. Two heaps: `lower` (a max-heap) holds the smaller half and
// `upper` (a min-heap) the larger half. Every value in lower is ≤ every value in upper, and lower has
// the same number of values as upper or one more. Then the median is lower's top (odd count) or the
// mean of both tops (even count). add is O(log n); median is O(1).

import DSAKit

public enum RunningMedian {
    public struct MedianTracker {
        private var lower = Heap<Int>.maxHeap()
        private var upper = Heap<Int>.minHeap()

        public init() {}

        public var count: Int {
            lower.count + upper.count
        }

        public mutating func add(_ value: Int) {
            if let top = lower.peek(), value > top {
                upper.insert(value)
            } else {
                lower.insert(value)
            }
            // Rebalance so that lower has as many values as upper, or one more
            if lower.count > upper.count + 1 {
                upper.insert(lower.pop()!)
            } else if upper.count > lower.count {
                lower.insert(upper.pop()!)
            }
        }

        public var median: Double? {
            guard let middle = lower.peek() else { return nil }
            if lower.count > upper.count {
                return Double(middle)
            }
            return (Double(middle) + Double(upper.peek()!)) / 2
        }
    }
}
