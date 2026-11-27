// Reference solution: Lowest common ancestor in a BST. Walk down from the root. If both values are
// smaller than the node's, both are in its left subtree; if both are bigger, both are on the right.
// Otherwise they split here (or one of them is this node), so this is the lowest node above both.
// O(h) time, O(1) space.

import DSAKit

public enum BSTCommonAncestor {
    public static func lowest(of first: Int, and second: Int, in root: TreeNode?) -> TreeNode? {
        var current = root
        while let node = current {
            if first < node.value && second < node.value {
                current = node.left
            } else if first > node.value && second > node.value {
                current = node.right
            } else {
                return node
            }
        }
        return nil
    }
}
