// Problem: Min stack (M26 · Min stack)

public enum MinStackDesign {
    /// A stack of integers that can also report its smallest element. Every operation is O(1).
    public struct MinStack {
        // Add your storage here

        public init() {
            // Write your solution here, then run:
            // swift test --filter MinStackDesignTests
        }

        /// Puts `value` on top.
        public mutating func push(_ value: Int) {
        }

        /// Removes and returns the top value, or returns nil if the stack is empty.
        @discardableResult
        public mutating func pop() -> Int? {
            return nil
        }

        /// The top value, or nil if the stack is empty.
        public var top: Int? {
            return nil
        }

        /// The smallest value in the stack, or nil if it's empty.
        public var minimum: Int? {
            return nil
        }

        /// How many values the stack holds.
        public var count: Int {
            return 0
        }
    }
}
