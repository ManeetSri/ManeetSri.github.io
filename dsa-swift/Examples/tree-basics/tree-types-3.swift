// Generated from src/dsa/content/lessons/tree-basics/tree-types.mdx. Edit the lesson, then run
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

func isFull(_ node: TreeNode?) -> Bool {
    guard let node else { return true }
    if (node.left == nil) != (node.right == nil) {
        return false                         // exactly one child
    }
    return isFull(node.left) && isFull(node.right)
}

func counts(_ node: TreeNode?) -> (inner: Int, leaves: Int) {
    guard let node else { return (0, 0) }
    if node.left == nil && node.right == nil { return (0, 1) }
    let left = counts(node.left)
    let right = counts(node.right)
    return (1 + left.inner + right.inner, left.leaves + right.leaves)
}

let trees = [
    TreeNode(1, left: TreeNode(2, left: TreeNode(4), right: TreeNode(5)), right: TreeNode(3)),
    TreeNode(1, left: TreeNode(2), right: TreeNode(3, left: TreeNode(4), right: TreeNode(5, left: TreeNode(6), right: TreeNode(7)))),
    TreeNode(1, left: TreeNode(2, left: TreeNode(4), right: TreeNode(5)), right: TreeNode(3, right: TreeNode(6))),
]
for tree in trees {
    let (inner, leaves) = counts(tree)
    print("full: \(isFull(tree)), internal \(inner), leaves \(leaves)")
}
