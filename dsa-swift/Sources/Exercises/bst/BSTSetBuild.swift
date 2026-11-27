// Problem: Build a binary search tree set (M37 · Build a generic BST<Element: Comparable>)

public enum BSTSetBuild {
    /// A set of Comparable elements kept in a binary search tree: each element at most once, every
    /// lookup and change O(h), where h is the height, and the elements available in increasing order.
    public struct SearchTreeSet<Element: Comparable> {
        // Write your solution here, then run:
        // swift test --filter BSTSetBuildTests
        // Add whatever storage you need: a node class with left and right children, and a root.

        /// Creates an empty set.
        public init() {}

        /// How many elements the set holds.
        public var count: Int {
            return 0
        }

        /// True when the set holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// True if the set holds `element`.
        public func contains(_ element: Element) -> Bool {
            return false
        }

        /// Adds `element` and returns true, or returns false if it was already there.
        @discardableResult
        public mutating func insert(_ element: Element) -> Bool {
            return false
        }

        /// Removes `element` and returns it, or returns nil if it wasn't there.
        @discardableResult
        public mutating func remove(_ element: Element) -> Element? {
            return nil
        }

        /// The smallest element, or nil if the set is empty.
        public var min: Element? {
            return nil
        }

        /// The largest element, or nil if the set is empty.
        public var max: Element? {
            return nil
        }

        /// The largest element less than or equal to `element`, or nil if there's none.
        public func floor(_ element: Element) -> Element? {
            return nil
        }

        /// The smallest element greater than or equal to `element`, or nil if there's none.
        public func ceiling(_ element: Element) -> Element? {
            return nil
        }

        /// Every element, in increasing order.
        public var inOrder: [Element] {
            return []
        }
    }
}
