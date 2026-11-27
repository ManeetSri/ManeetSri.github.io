// Problem: A head-index queue that gives memory back (M27 · A queue with a head index)

public enum CompactingIndexQueue {
    /// A first-in, first-out queue on an array with a head index. Dead slots are cleaned up so that
    /// `slotCount ≤ 2 × count + 16` after every operation, and an emptied queue holds no slots.
    public struct TicketQueue<Element> {
        // Write your solution here, then run:
        // swift test --filter CompactingIndexQueueTests
        // Add whatever private storage you need: an array and a head index.

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

        /// How many slots the backing array holds, live and dead together.
        public var slotCount: Int {
            return -1
        }

        /// Adds `element` at the back.
        public mutating func enqueue(_ element: Element) {
        }

        /// Removes and returns the front item, or nil if the queue is empty.
        public mutating func dequeue() -> Element? {
            return nil
        }

        /// Returns the front item without removing it, or nil if the queue is empty.
        public func peek() -> Element? {
            return nil
        }
    }
}
