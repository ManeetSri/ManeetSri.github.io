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

// Buggy: uses real Int values to mean "no limit"
func isValidSentinel(_ node: TreeNode?, low: Int = Int.min, high: Int = Int.max) -> Bool {
    guard let node else { return true }
    if node.value <= low || node.value >= high { return false }
    return isValidSentinel(node.left, low: low, high: node.value)
        && isValidSentinel(node.right, low: node.value, high: high)
}

print(isValidSentinel(TreeNode(5)))
print(isValidSentinel(TreeNode(Int.min)))
print(isValidSentinel(TreeNode(0, right: TreeNode(Int.max))))
