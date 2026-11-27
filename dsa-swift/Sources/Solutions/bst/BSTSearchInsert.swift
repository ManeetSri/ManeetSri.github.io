// Reference solution: Search and insert in a BST. Both walk one path down from the root, going left
// when the value is smaller than the node's and right when it's bigger, so each costs O(h) time for a
// tree of height h. Loops rather than recursion keep the extra space at O(1), and very deep trees are
// fine.

import DSAKit

public enum BSTSearchInsert {
    public static func search(_ target: Int, in root: TreeNode?) -> TreeNode? {
        var current = root
        while let node = current {
            if target == node.value {
                return node
            }
            current = target < node.value ? node.left : node.right
        }
        return nil
    }

    public static func insert(_ value: Int, into root: TreeNode?) -> TreeNode {
        guard let root else { return TreeNode(value) }
        var node = root
        while true {
            if value < node.value {
                guard let left = node.left else {
                    node.left = TreeNode(value)
                    return root
                }
                node = left
            } else if value > node.value {
                guard let right = node.right else {
                    node.right = TreeNode(value)
                    return root
                }
                node = right
            } else {
                return root                       // already there: a BST holds each value once
            }
        }
    }
}
