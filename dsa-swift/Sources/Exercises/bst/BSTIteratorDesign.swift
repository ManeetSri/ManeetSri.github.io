// Problem: Design a BST iterator (M37 · Floor, ceiling and a BST iterator)

import DSAKit

public enum BSTIteratorDesign {
    /// Walks a binary search tree in increasing order, one value per `next()` call, without copying
    /// the values out first. Aim for O(h) memory, where h is the height, and amortised O(1) per call.
    public struct InorderIterator: IteratorProtocol {
        // Write your solution here, then run:
        // swift test --filter BSTIteratorDesignTests
        // Add whatever private storage you need: a stack of nodes still to visit.

        /// Creates an iterator over the tree `root`, ready to return its smallest value.
        public init(_ root: TreeNode?) {}

        /// Returns the next value in increasing order, or nil once every value has been returned.
        public mutating func next() -> Int? {
            return nil
        }

        /// True if `next()` has another value to return.
        public var hasNext: Bool {
            return false
        }

        /// The value the next `next()` call will return, without moving on, or nil if there's none.
        public func peek() -> Int? {
            return nil
        }
    }
}
