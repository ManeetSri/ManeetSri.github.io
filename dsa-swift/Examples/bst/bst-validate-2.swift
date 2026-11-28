// Generated from src/dsa/content/lessons/bst/bst-validate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

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

// low and high are exclusive bounds; nil means "no limit on this side"
func isValid(_ node: TreeNode?, low: Int? = nil, high: Int? = nil) -> Bool {
    guard let node else { return true }
    if let low, node.value <= low { return false }
    if let high, node.value >= high { return false }
    return isValid(node.left, low: low, high: node.value)
        && isValid(node.right, low: node.value, high: high)
}

let tricky = TreeNode(10, left: TreeNode(5), right: TreeNode(15, left: TreeNode(6), right: TreeNode(20)))
let good = TreeNode(10, left: TreeNode(5), right: TreeNode(15, left: TreeNode(12), right: TreeNode(20)))
let repeated = TreeNode(10, left: TreeNode(5, right: TreeNode(10)))
let extremes = TreeNode(0, left: TreeNode(Int.min), right: TreeNode(Int.max))
print(isValid(tricky), isValid(good), isValid(repeated), isValid(extremes), isValid(nil))
