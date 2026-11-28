// Problem: A priority queue with both ends (M69 · swift-collections)

public enum MinMaxPriorityQueue {
    /// A double-ended priority queue: O(1) `min` and `max`, O(log n) `insert`, `popMin` and `popMax`.
    /// No packages and no DSAKit.
    public struct Queue<Element: Comparable> {
        // Write your solution here, then run:
        // swift test --filter MinMaxPriorityQueueTests
        // Add whatever private storage you need, for example `private var items: [Element] = []`.

        /// Creates an empty queue.
        public init() {}

        /// Creates a queue holding `elements`. Aim for O(n).
        public init(_ elements: [Element]) {}

        /// How many elements the queue holds.
        public var count: Int {
            return 0
        }

        /// True when the queue holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// The smallest element, or nil if the queue is empty. O(1).
        public var min: Element? {
            return nil
        }

        /// The largest element, or nil if the queue is empty. O(1).
        public var max: Element? {
            return nil
        }

        /// Adds an element. O(log n).
        public mutating func insert(_ element: Element) {
        }

        /// Removes and returns the smallest element, or nil if the queue is empty. O(log n).
        public mutating func popMin() -> Element? {
            return nil
        }

        /// Removes and returns the largest element, or nil if the queue is empty. O(log n).
        public mutating func popMax() -> Element? {
            return nil
        }
    }
}
