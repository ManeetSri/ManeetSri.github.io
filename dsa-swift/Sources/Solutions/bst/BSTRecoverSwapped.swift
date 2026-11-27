// Reference solution: Repair a BST with two swapped values. An inorder walk of a correct BST is
// increasing, so the swap shows up as "drops", places where a value is smaller than the one before.
// Swapping neighbours in sorted order makes one drop; swapping values further apart makes two. The
// first wrong node is the bigger value at the first drop, and the second is the smaller value at the
// last drop. Swap their values back. An iterative inorder walk: O(n) time, O(h) space.

import DSAKit

public enum BSTRecoverSwapped {
    public static func repair(_ root: TreeNode?) {
        var first: TreeNode? = nil
        var second: TreeNode? = nil
        var previous: TreeNode? = nil
        var stack: [TreeNode] = []
        var current = root
        while current != nil || !stack.isEmpty {
            while let node = current {
                stack.append(node)
                current = node.left
            }
            let node = stack.removeLast()
            if let previous, previous.value > node.value {
                if first == nil {
                    first = previous
                }
                second = node
            }
            previous = node
            current = node.right
        }
        if let first, let second {
            (first.value, second.value) = (second.value, first.value)
        }
    }
}
