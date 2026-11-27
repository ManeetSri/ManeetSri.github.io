// Problem: The boundary of a tree (M35 · Vertical order and boundary traversal)

import DSAKit

public enum TreeBoundary {
    /// The values around the outside of the tree, anticlockwise from the root, each node once:
    /// 1. the root;
    /// 2. the left edge: start at the root's left child and keep moving to the left child, or to the
    ///    right child when there's no left one, stopping before a leaf; top to bottom;
    /// 3. every leaf, left to right;
    /// 4. the right edge: start at the root's right child and keep moving to the right child, or to the
    ///    left child when there's no right one, stopping before a leaf; bottom to top.
    /// A root with no children is just `[root]`. The empty tree gives `[]`.
    public static func boundary(_ root: TreeNode?) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter TreeBoundaryTests
        return []
    }
}
