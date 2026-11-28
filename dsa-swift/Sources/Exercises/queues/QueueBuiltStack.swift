// Problem: A stack from queues (M27 · A stack from queues)

import DSAKit

public enum QueueBuiltStack {
    /// A last-in, first-out stack stored only in DSAKit `Queue`s (enqueue, dequeue, peek, count and
    /// isEmpty), plus at most one extra element. push and top are O(1); pop may be O(n).
    public struct QueueStack<Element> {
        // Write your solution here, then run:
        // swift test --filter QueueBuiltStackTests
        // Add whatever private storage you need: queues, and one extra element.

        /// Creates an empty stack.
        public init() {}

        /// How many elements the stack holds.
        public var count: Int {
            return 0
        }

        /// True when the stack holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// Puts `element` on top. O(1).
        public mutating func push(_ element: Element) {
        }

        /// Removes and returns the top element, or nil if the stack is empty.
        public mutating func pop() -> Element? {
            return nil
        }

        /// Returns the top element without removing it, or nil if the stack is empty. O(1).
        public func top() -> Element? {
            return nil
        }
    }
}
