// Reference solution: Longest path in a tree. One post-order pass. Each call returns its subtree's
// height in levels, and on the way it checks the longest path that bends at that node, left height +
// right height edges, against the best so far: "return a height, update a global best". O(n) time,
// O(h) stack space for a tree h levels tall.

import DSAKit

public enum LongestTreePath {
    public static func diameter(of root: TreeNode?) -> Int {
        var best = 0
        func height(_ node: TreeNode?) -> Int {
            guard let node else { return 0 }
            let left = height(node.left)
            let right = height(node.right)
            best = max(best, left + right)       // the longest path bending at node, in edges
            return 1 + max(left, right)
        }
        _ = height(root)
        return best
    }
}
