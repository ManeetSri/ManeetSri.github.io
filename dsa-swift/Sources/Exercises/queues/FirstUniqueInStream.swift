// Problem: First unique in a stream (M27 · Stream problems: first unique, moving average)

public enum FirstUniqueInStream {
    /// Watches a stream of elements and knows, after each one, the earliest element that has
    /// appeared exactly once so far.
    public struct UniqueWatcher<Element: Hashable> {
        // Write your solution here, then run:
        // swift test --filter FirstUniqueInStreamTests
        // Add whatever private storage you need.

        /// Creates a watcher that hasn't seen anything yet.
        public init() {}

        /// Adds the next element of the stream.
        public mutating func add(_ element: Element) {
        }

        /// The element that appeared earliest among those seen exactly once, or nil if there's none.
        public var firstUnique: Element? {
            return nil
        }
    }
}
