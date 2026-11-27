// Problem: Delete a value from a BST (M37 · Deleting from a BST)

import DSAKit

public enum BSTDeleteNode {
    /// Removes the node holding `value` from the binary search tree `root` and returns the root of the
    /// result, which may be a different node, or nil if the tree becomes empty. If `value` isn't there,
    /// returns the tree unchanged. The result must still be a binary search tree, and no taller than
    /// before. Aim for O(h), where h is the height.
    public static func remove(_ value: Int, from root: TreeNode?) -> TreeNode? {
        // Write your solution here, then run:
        // swift test --filter BSTDeleteNodeTests
        return root
    }
}
