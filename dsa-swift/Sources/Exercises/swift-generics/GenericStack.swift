// Problem: A generic stack (M10 · Generic types: Stack<Element>)

public enum GenericStack {
    /// A last-in, first-out stack that can hold any type of element.
    public struct Stack<Element> {
        // Write your solution here, then run:
        // swift test --filter GenericStackTests
        // Add whatever private storage you need.

        /// Creates an empty stack.
        public init() {}

        /// Puts `element` on top of the stack.
        public mutating func push(_ element: Element) {
        }

        /// Removes and returns the top element, or nil if the stack is empty.
        public mutating func pop() -> Element? {
            return nil
        }

        /// Returns the top element without removing it, or nil if the stack is empty.
        public func peek() -> Element? {
            return nil
        }

        /// True when the stack holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// How many elements the stack holds.
        public var count: Int {
            return 0
        }
    }

    /// Applies `edits` in order: "UNDO" removes the most recently added word that's still there
    /// (and does nothing if there's none); anything else adds that word. Returns the remaining words
    /// in the order they were added, joined by single spaces, or "" if none remain.
    public static func finalText(after edits: [String]) -> String {
        return ""
    }
}
