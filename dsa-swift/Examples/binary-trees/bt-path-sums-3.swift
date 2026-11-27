// Generated from src/dsa/content/lessons/binary-trees/bt-path-sums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countForgetful(in root: TreeNode?, summingTo target: Int) -> Int {
    var seen: [Int: Int] = [0: 1]
    var count = 0
    func walk(_ node: TreeNode?, _ runningAbove: Int) {
        guard let node else { return }
        let running = runningAbove + node.value
        count += seen[running - target, default: 0]
        seen[running, default: 0] += 1
        walk(node.left, running)
        walk(node.right, running)
        // missing: seen[running, default: 0] -= 1
    }
    walk(root, 0)
    return count
}

// 5 → 3 → 2 on the left, 5 → −3 → 8 on the right. Paths summing to 2: [2] and [5, −3].
let tree = TreeNode(5, left: TreeNode(3, left: TreeNode(2)), right: TreeNode(-3, right: TreeNode(8)))
print(countForgetful(in: tree, summingTo: 2))

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
