// Problem: Lazy nested-list iterator (M72 · Iterators: peeking, flatten nested and zigzag)

public enum LazyNestedIterator {
    /// Either a single number, or a list whose items are themselves numbers or lists.
    public enum Item: Equatable {
        case number(Int)
        case list([Item])
    }

    /// Hands out the numbers inside a nested list one at a time, from left to right, doing only as
    /// much work as each call needs.
    public struct Flattener: IteratorProtocol, Sequence {
        // Write your solution here, then run:
        // swift test --filter LazyNestedIteratorTests
        // Add whatever private storage you need. Don't flatten everything in init.

        /// Creates an iterator over the numbers in `items`. O(1): no work happens until asked.
        public init(_ items: [Item]) {
        }

        /// The next number without consuming it, or nil when there are no numbers left. Calling it
        /// again returns the same number.
        public mutating func peek() -> Int? {
            return nil
        }

        /// Returns the next number and moves past it, or nil when there are no numbers left.
        public mutating func next() -> Int? {
            return nil
        }
    }
}
