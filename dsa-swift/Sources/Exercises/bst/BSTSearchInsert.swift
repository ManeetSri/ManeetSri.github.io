// Problem: Search and insert in a BST (M37 · The BST property, search and insert)

import DSAKit

public enum BSTSearchInsert {
    /// Returns the node holding `target` in the binary search tree `root`, or nil if no node holds it.
    /// Aim for O(h), where h is the height.
    public static func search(_ target: Int, in root: TreeNode?) -> TreeNode? {
        // Write your solution here, then run:
        // swift test --filter BSTSearchInsertTests
        return nil
    }

    /// Adds `value` to the binary search tree `root` as a new leaf and returns the root: `root` itself,
    /// or the new node if the tree was empty. If `value` is already there, the tree is unchanged.
    /// Aim for O(h).
    public static func insert(_ value: Int, into root: TreeNode?) -> TreeNode {
        // Write your solution here, then run:
        // swift test --filter BSTSearchInsertTests
        return TreeNode(value)
    }
}
