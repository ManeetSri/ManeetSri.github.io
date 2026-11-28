// Reference solution: Zigzag levels and side views. All three come from the same level-by-level
// walk: build each level's nodes left to right, then take what the question wants from it. Zigzag
// reverses every second level's values; the right view keeps each level's last node, the left view
// its first. O(n) time, O(w) space for the widest level w.

import DSAKit

public enum ZigzagSideViews {
    /// Every level's values, left to right, top down.
    private static func levels(_ root: TreeNode?) -> [[Int]] {
        var result: [[Int]] = []
        var level = [root].compactMap { $0 }
        while !level.isEmpty {
            result.append(level.map(\.value))
            level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
        }
        return result
    }

    public static func zigzag(_ root: TreeNode?) -> [[Int]] {
        levels(root).enumerated().map { depth, values in
            depth % 2 == 0 ? values : Array(values.reversed())
        }
    }

    public static func rightView(_ root: TreeNode?) -> [Int] {
        levels(root).map { $0[$0.count - 1] }     // every level has at least one node
    }

    public static func leftView(_ root: TreeNode?) -> [Int] {
        levels(root).map { $0[0] }
    }
}
