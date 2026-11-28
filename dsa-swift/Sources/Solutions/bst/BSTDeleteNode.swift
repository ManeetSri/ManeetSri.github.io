// Reference solution: Delete a value from a BST. Recurse down to the node, and have every call return
// the root of its subtree after the deletion, so each parent re-links whatever comes back. At the node:
// with no left child, the right subtree takes its place (that covers a leaf too); with no right child,
// the left subtree does. With two children, copy in the inorder successor (the smallest value in the
// right subtree) and delete that value from the right subtree instead; the successor has no left
// child, so that second deletion is the easy case. O(h) time and O(h) stack for a tree of height h,
// and the tree never gets taller.

import DSAKit

public enum BSTDeleteNode {
    public static func remove(_ value: Int, from root: TreeNode?) -> TreeNode? {
        guard let node = root else { return nil }
        if value < node.value {
            node.left = remove(value, from: node.left)
        } else if value > node.value {
            node.right = remove(value, from: node.right)
        } else {
            guard let left = node.left else { return node.right }
            guard let right = node.right else { return left }
            var successor = right
            while let smaller = successor.left {
                successor = smaller
            }
            node.value = successor.value
            node.right = remove(successor.value, from: right)
        }
        return node
    }
}
