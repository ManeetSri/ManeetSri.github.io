// Reference solution: Target sum paths.
// - rootToLeafPaths: a depth-first walk keeps the current path in one array, appending on the way down
//   and removing on the way back up (backtracking), and copies it out at each matching leaf. O(n · h)
//   for the copies in the worst case, O(h) extra space besides the answer.
// - downwardPathCount: the prefix-sum + dictionary idea from subarray sums, run along each root-to-node
//   path. The dictionary counts the running sums of the nodes above, so a path ending here exists for
//   every earlier running sum equal to running − target. On the way back up, the running sum is
//   removed again, because it's no longer on the path. O(n) time, O(h) space.

import DSAKit

public enum TargetSumPaths {
    public static func rootToLeafPaths(in root: TreeNode?, summingTo target: Int) -> [[Int]] {
        var result: [[Int]] = []
        var path: [Int] = []
        func walk(_ node: TreeNode?, remaining: Int) {
            guard let node else { return }
            path.append(node.value)
            let stillNeeded = remaining - node.value
            if node.left == nil && node.right == nil {
                if stillNeeded == 0 {
                    result.append(path)
                }
            } else {
                walk(node.left, remaining: stillNeeded)
                walk(node.right, remaining: stillNeeded)
            }
            path.removeLast()                        // backtrack
        }
        walk(root, remaining: target)
        return result
    }

    public static func downwardPathCount(in root: TreeNode?, summingTo target: Int) -> Int {
        var seen: [Int: Int] = [0: 1]                // running sums above the current node: the empty path
        var count = 0
        func walk(_ node: TreeNode?, runningAbove: Int) {
            guard let node else { return }
            let running = runningAbove + node.value
            count += seen[running - target, default: 0]
            seen[running, default: 0] += 1
            walk(node.left, runningAbove: running)
            walk(node.right, runningAbove: running)
            seen[running, default: 0] -= 1           // backtrack: this sum leaves the path
        }
        walk(root, runningAbove: 0)
        return count
    }
}
