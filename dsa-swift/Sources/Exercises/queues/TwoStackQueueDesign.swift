// Problem: A queue from two stacks (M27 · A queue from two stacks)

public enum TwoStackQueueDesign {
    /// A first-in, first-out queue built from two stacks (arrays used only with `append`,
    /// `popLast()`, `last`, `first`, `isEmpty` and `count`). Every operation should be amortised O(1).
    public struct TwoStackQueue<Element> {
        // Write your solution here, then run:
        // swift test --filter TwoStackQueueDesignTests
        // Add whatever private storage you need: two arrays, used as stacks.

        /// Creates an empty queue.
        public init() {}

        /// Adds `element` at the back of the queue.
        public mutating func enqueue(_ element: Element) {
        }

        /// Removes and returns the front element, or nil if the queue is empty.
        public mutating func dequeue() -> Element? {
            return nil
        }

        /// Returns the front element without removing it, or nil if the queue is empty.
        public func peek() -> Element? {
            return nil
        }

        /// True when the queue holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// How many elements the queue holds.
        public var count: Int {
            return 0
        }
    }
}
