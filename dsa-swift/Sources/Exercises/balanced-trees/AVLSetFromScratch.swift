// Problem: Build an AVL tree (M38 · AVL trees: insert and delete)

public enum AVLSetFromScratch {
    /// One node of the tree. Written for you: keep `height` up to date (1 for a leaf, 1 more than the
    /// taller child otherwise) whenever a node's children change.
    public final class Node {
        public var value: Int
        public var left: Node?
        public var right: Node?
        public var height = 1

        public init(_ value: Int) {
            self.value = value
        }
    }

    /// A set of Ints stored in an AVL tree: every node's balance factor, height(left) − height(right),
    /// stays −1, 0 or 1, so insert, remove and contains are O(log n).
    public final class AVLSet {
        /// The root node, or nil when the set is empty. Only the set itself changes it.
        public private(set) var root: Node?

        /// How many values the set holds.
        public private(set) var count = 0

        public init() {}

        /// True if `value` is in the set. O(log n).
        public func contains(_ value: Int) -> Bool {
            // Write your solution here, then run:
            // swift test --filter AVLSetFromScratchTests
            return false
        }

        /// Inserts `value` and returns true, or returns false (changing nothing) if it's already there.
        /// Rebalances on the way back up. O(log n).
        @discardableResult
        public func insert(_ value: Int) -> Bool {
            return false
        }

        /// Removes `value` and returns true, or returns false if it isn't there. A node with two
        /// children takes its successor's value (the smallest in its right subtree), and the successor
        /// is removed instead. Rebalances every node on the way back up. O(log n).
        @discardableResult
        public func remove(_ value: Int) -> Bool {
            return false
        }

        // Written for you ───────────────────────────────────────────────────────────────────────

        /// The number of levels: 0 when empty. O(1).
        public var height: Int {
            root?.height ?? 0
        }

        /// The values in increasing order (an inorder walk with a stack). O(n).
        public var sorted: [Int] {
            var result: [Int] = []
            var stack: [Node] = []
            var current = root
            while current != nil || !stack.isEmpty {
                while let node = current {
                    stack.append(node)
                    current = node.left
                }
                let node = stack.removeLast()
                result.append(node.value)
                current = node.right
            }
            return result
        }

        /// The tree level by level, with nil for each missing child of a node that exists and trailing
        /// nils removed: inserting 1, 2, 3 should give [2, 1, 3]. O(n).
        public var levelOrder: [Int?] {
            var result: [Int?] = []
            var queue: [Node?] = [root]
            var head = 0
            while head < queue.count {
                let node = queue[head]
                head += 1
                if let node {
                    result.append(node.value)
                    queue.append(node.left)
                    queue.append(node.right)
                } else {
                    result.append(nil)
                }
            }
            while let last = result.last, last == nil {
                result.removeLast()
            }
            return result
        }
    }
}
