// Problem: Tree census (M34 · Tree terminology)

import DSAKit

public enum TreeCensus {
    /// The number of nodes in the tree. The empty tree (nil) has 0. Write it yourself rather than
    /// using DSAKit's `count`.
    public static func size(_ root: TreeNode?) -> Int {
        // Write your solution here, then run:
        // swift test --filter TreeCensusTests
        return 0
    }

    /// The number of leaves: nodes with no children at all.
    public static func leaves(_ root: TreeNode?) -> Int {
        return 0
    }

    /// The depth of the node holding `value`, counted in edges from the root (the root has depth 0),
    /// or nil if no node holds it. The values in the tree are distinct.
    public static func depth(of value: Int, in root: TreeNode?) -> Int? {
        return nil
    }
}
