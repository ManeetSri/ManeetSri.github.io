// Problem: Balance, mirror and subtree checks (M36 · Balanced, same and symmetric trees; Invert a tree
// and subtree of another)

import DSAKit

public enum BalanceMirrorChecks {
    /// True when, at every node, the heights of its left and right subtrees differ by at most 1. The empty
    /// tree is balanced. Aim for O(n): compute each height once.
    public static func isBalanced(_ root: TreeNode?) -> Bool {
        // Write your solution here, then run:
        // swift test --filter BalanceMirrorChecksTests
        return false
    }

    /// True when the tree is its own mirror image: the left half, reflected, matches the right half in
    /// shape and values. The empty tree is symmetric.
    public static func isSymmetric(_ root: TreeNode?) -> Bool {
        return false
    }

    /// Turns the tree into its mirror image in place, by swapping the children of every node, and returns
    /// the root. Reuse the nodes: don't create any.
    @discardableResult
    public static func mirrored(_ root: TreeNode?) -> TreeNode? {
        return nil
    }

    /// True when some node of `tree`, together with everything below it, is exactly `pattern`: same shape
    /// and same values. An empty pattern is inside every tree.
    public static func contains(_ pattern: TreeNode?, in tree: TreeNode?) -> Bool {
        return false
    }
}
