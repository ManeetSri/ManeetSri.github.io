// Problem: Target sum paths (M36 · Path sum I, II and III)

import DSAKit

public enum TargetSumPaths {
    /// Every path from the root down to a leaf whose values add up to `target`, each as its list of
    /// values from the root down. Paths are listed in the order of their leaves from left to right.
    public static func rootToLeafPaths(in root: TreeNode?, summingTo target: Int) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter TargetSumPathsTests
        return []
    }

    /// How many downward paths add up to `target`. A downward path starts at any node and goes down
    /// through children to any node below it (or stops where it started). Aim for O(n).
    public static func downwardPathCount(in root: TreeNode?, summingTo target: Int) -> Int {
        return 0
    }
}
