// Generated from src/dsa/content/lessons/bst/bst-property-search-insert.mdx. Edit the lesson, then run
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

func inorder(_ node: TreeNode?, _ visit: (Int) -> Void) {
    guard let node else { return }
    inorder(node.left, visit)
    visit(node.value)
    inorder(node.right, visit)
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
var values: [Int] = []
inorder(root) { values.append($0) }
print(values)
