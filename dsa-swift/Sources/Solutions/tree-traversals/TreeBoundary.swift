// Reference solution: The boundary of a tree. Three separate walks, glued together:
// - the left edge: a loop down from the root's left child, preferring left, stopping at a leaf;
// - the leaves: a preorder walk with an explicit stack (right pushed before left, so leaves come out
//   left to right);
// - the right edge: a loop down from the root's right child, preferring right, reversed at the end.
// Leaves are excluded from both edges, so nothing is listed twice. O(n) time, O(h) extra space, and
// no recursion.

import DSAKit

public enum TreeBoundary {
    private static func isLeaf(_ node: TreeNode) -> Bool {
        node.left == nil && node.right == nil
    }

    public static func boundary(_ root: TreeNode?) -> [Int] {
        guard let root else { return [] }
        var result = [root.value]
        if isLeaf(root) {
            return result
        }

        var next = root.left
        while let node = next, !isLeaf(node) {
            result.append(node.value)
            next = node.left ?? node.right
        }

        var stack = [root]
        while let node = stack.popLast() {
            if isLeaf(node) {
                result.append(node.value)
            }
            if let right = node.right { stack.append(right) }
            if let left = node.left { stack.append(left) }
        }

        var rightEdge: [Int] = []
        next = root.right
        while let node = next, !isLeaf(node) {
            rightEdge.append(node.value)
            next = node.right ?? node.left
        }
        result += rightEdge.reversed()
        return result
    }
}
