// Reference solution: Best path sum. One post-order pass. Each call returns the node's gain: the best
// sum of a path that starts at the node and goes down one side, never below 0 because a negative branch
// can be left off. On the way, the best path that bends at the node, value + left gain + right gain, is
// checked against the best so far. O(n) time, O(h) stack space.

import DSAKit

public enum RichestTreePath {
    public static func maximumPathSum(_ root: TreeNode?) -> Int? {
        guard let root else { return nil }
        var best = root.value                        // any single node is a path
        func gain(_ node: TreeNode?) -> Int {
            guard let node else { return 0 }
            let left = max(0, gain(node.left))
            let right = max(0, gain(node.right))
            best = max(best, node.value + left + right)
            return node.value + max(left, right)
        }
        _ = gain(root)
        return best
    }
}
