// Reference solution: Validate a binary search tree. Every node must lie strictly between bounds set
// by its ancestors: going left, the parent's value becomes the upper bound; going right, it becomes the
// lower bound. The bounds start as nil (no limit) rather than Int.min and Int.max, so a tree that
// really holds Int.min or Int.max is judged correctly. An explicit stack carries each node with its
// bounds. O(n) time, O(h) space.

import DSAKit

public enum BSTValidate {
    public static func isValid(_ root: TreeNode?) -> Bool {
        var stack: [(node: TreeNode, low: Int?, high: Int?)] = []
        if let root {
            stack.append((root, nil, nil))
        }
        while let (node, low, high) = stack.popLast() {
            if let low, node.value <= low { return false }
            if let high, node.value >= high { return false }
            if let left = node.left {
                stack.append((left, low, node.value))
            }
            if let right = node.right {
                stack.append((right, node.value, high))
            }
        }
        return true
    }
}
