// Reference solution: Design a BST iterator. The stack holds the nodes still to visit whose left
// subtrees are already done, smallest on top: at most one node per level, O(h) memory. `next()` pops
// the top and pushes the left spine of its right subtree. One call can push many nodes, but every node
// is pushed once and popped once over the whole walk, so `next()` is amortised O(1).

import DSAKit

public enum BSTIteratorDesign {
    public struct InorderIterator: IteratorProtocol {
        private var stack: [TreeNode] = []

        public init(_ root: TreeNode?) {
            pushLeftSpine(from: root)
        }

        private mutating func pushLeftSpine(from start: TreeNode?) {
            var current = start
            while let node = current {
                stack.append(node)
                current = node.left
            }
        }

        public mutating func next() -> Int? {
            guard let node = stack.popLast() else { return nil }
            pushLeftSpine(from: node.right)
            return node.value
        }

        public var hasNext: Bool {
            !stack.isEmpty
        }

        public func peek() -> Int? {
            stack.last?.value
        }
    }
}
