// Problem: Merge two linked queues in O(1) (M27 · A linked-list queue)

public enum SpliceableLinkedQueue {
    /// A first-in, first-out queue built from linked nodes. Every operation is O(1) in the worst case,
    /// including `absorb`, which moves a whole queue onto the back of this one.
    public final class LinkedQueue<Element> {
        // Write your solution here, then run:
        // swift test --filter SpliceableLinkedQueueTests
        // Add a node class, `head`, `tail` and a count.

        /// Creates an empty queue.
        public init() {}

        /// How many items are waiting.
        public var count: Int {
            return 0
        }

        /// True when no items are waiting.
        public var isEmpty: Bool {
            return true
        }

        /// Adds `element` at the back.
        public func enqueue(_ element: Element) {
        }

        /// Removes and returns the front item, or nil if the queue is empty.
        public func dequeue() -> Element? {
            return nil
        }

        /// Returns the front item without removing it, or nil if the queue is empty.
        public func peek() -> Element? {
            return nil
        }

        /// The items from front to back.
        public var values: [Element] {
            return []
        }

        /// Moves every item of `other` to the back of this queue, in order, leaving `other` empty.
        /// O(1). Does nothing if `other` is this queue.
        public func absorb(_ other: LinkedQueue<Element>) {
        }
    }
}
