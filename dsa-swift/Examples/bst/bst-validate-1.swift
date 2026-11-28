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

// Wrong: only compares each node with its own children
func childrenLookFine(_ node: TreeNode?) -> Bool {
    guard let node else { return true }
    if let left = node.left, left.value >= node.value { return false }
    if let right = node.right, right.value <= node.value { return false }
    return childrenLookFine(node.left) && childrenLookFine(node.right)
}

//      10
//     /  \
//    5    15
//        /  \
//       6    20
let tricky = TreeNode(10, left: TreeNode(5), right: TreeNode(15, left: TreeNode(6), right: TreeNode(20)))
print(childrenLookFine(tricky))
