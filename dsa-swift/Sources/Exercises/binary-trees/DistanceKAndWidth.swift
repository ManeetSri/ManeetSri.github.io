// Problem: Nodes at distance K, and maximum width (M36 · Distance-K nodes and maximum width)

import DSAKit

public enum DistanceKAndWidth {
    /// The values of every node exactly `distance` edges from `target`, going up through parents as well
    /// as down through children, in increasing order. `target` is in the tree.
    public static func values(atDistance distance: Int, from target: TreeNode, in root: TreeNode?) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter DistanceKAndWidthTests
        return []
    }

    /// The width of the widest level. A level's width counts the places from its leftmost node to its
    /// rightmost node, including the places where a complete tree would have nodes but this one doesn't.
    public static func maximumWidth(_ root: TreeNode?) -> Int {
        return 0
    }
}
