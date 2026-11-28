// Problem: Zigzag levels and side views (M35 · Zigzag and the right, left, top and bottom views)

import DSAKit

public enum ZigzagSideViews {
    /// The values level by level, alternating direction: the root's level left to right, the next
    /// level right to left, the one after left to right again, and so on.
    public static func zigzag(_ root: TreeNode?) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter ZigzagSideViewsTests
        return []
    }

    /// What you'd see standing to the right of the tree: the rightmost node of each level, top down.
    public static func rightView(_ root: TreeNode?) -> [Int] {
        return []
    }

    /// What you'd see standing to the left: the leftmost node of each level, top down.
    public static func leftView(_ root: TreeNode?) -> [Int] {
        return []
    }
}
