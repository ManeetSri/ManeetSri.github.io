// Problem: Build a growable deque (M27 · Build Deque<T>)

public enum GrowableDeque {
    /// A double-ended queue on a growable ring buffer: amortised O(1) `append` and `prepend`,
    /// O(1) `popFirst`, `popLast`, `first`, `last` and access by position.
    public struct RingDeque<Element> {
        // Write your solution here, then run:
        // swift test --filter GrowableDequeTests
        // Add whatever private storage you need: slots, the front's slot and a count.

        /// Creates an empty deque.
        public init() {}

        /// Adds `element` at the back.
        public mutating func append(_ element: Element) {
        }

        /// Adds `element` at the front.
        public mutating func prepend(_ element: Element) {
        }

        /// Removes and returns the front element, or nil if the deque is empty.
        public mutating func popFirst() -> Element? {
            return nil
        }

        /// Removes and returns the back element, or nil if the deque is empty.
        public mutating func popLast() -> Element? {
            return nil
        }

        /// The front element, or nil if the deque is empty.
        public var first: Element? {
            return nil
        }

        /// The back element, or nil if the deque is empty.
        public var last: Element? {
            return nil
        }

        /// How many elements the deque holds.
        public var count: Int {
            return 0
        }

        /// True when the deque holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// The element at `position`, counting from 0 at the front, or nil if there's no such
        /// position.
        public subscript(position: Int) -> Element? {
            return nil
        }
    }
}
