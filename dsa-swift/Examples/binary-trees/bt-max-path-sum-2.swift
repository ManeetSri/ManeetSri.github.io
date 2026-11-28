// Generated from src/dsa/content/lessons/binary-trees/bt-max-path-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maximumPathSum(_ root: TreeNode) -> Int {
    var best = root.value
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

print(maximumPathSum(TreeNode(-3, left: TreeNode(-1), right: TreeNode(-2))))
print(maximumPathSum(TreeNode(2, left: TreeNode(-1))))
print(maximumPathSum(TreeNode(1, left: TreeNode(10, left: TreeNode(10), right: TreeNode(10)), right: TreeNode(10))))

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}
