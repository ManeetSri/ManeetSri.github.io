// Reference solution: Kth smallest value in a BST. An inorder walk visits values in increasing order,
// so the kth value visited is the answer. The walk uses an explicit stack and stops as soon as it gets
// there: O(h + k) time and O(h) space.

import DSAKit

public enum BSTKthSmallest {
    public static func value(_ k: Int, in root: TreeNode?) -> Int {
        var stack: [TreeNode] = []
        var current = root
        var visited = 0
        while current != nil || !stack.isEmpty {
            while let node = current {
                stack.append(node)
                current = node.left
            }
            let node = stack.removeLast()
            visited += 1
            if visited == k {
                return node.value
            }
            current = node.right
        }
        preconditionFailure("k is larger than the number of nodes")
    }
}
