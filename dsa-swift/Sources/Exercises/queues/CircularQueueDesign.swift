// Problem: Design a circular queue (M27 · Ring buffers)

public enum CircularQueueDesign {
    /// A first-in, first-out queue with a fixed capacity, stored in a ring of slots that never grows.
    /// When it's full, `enqueue` refuses the new element and returns false.
    public struct CircularQueue<Element> {
        // Write your solution here, then run:
        // swift test --filter CircularQueueDesignTests
        // Add whatever private storage you need: an array of `capacity` slots, made once in init.

        /// Creates an empty queue with room for `capacity` elements (at least 1).
        public init(capacity: Int) {
        }

        /// The most elements the queue can hold.
        public var capacity: Int {
            return 0
        }

        /// Adds `element` at the back and returns true, or returns false (changing nothing) if the
        /// queue is full.
        public mutating func enqueue(_ element: Element) -> Bool {
            return false
        }

        /// Removes and returns the front element, or nil if the queue is empty.
        public mutating func dequeue() -> Element? {
            return nil
        }

        /// The front (oldest) element, or nil if the queue is empty.
        public var front: Element? {
            return nil
        }

        /// The back (newest) element, or nil if the queue is empty.
        public var back: Element? {
            return nil
        }

        /// How many elements the queue holds.
        public var count: Int {
            return 0
        }

        /// True when the queue holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// True when the queue holds `capacity` elements.
        public var isFull: Bool {
            return false
        }
    }
}
