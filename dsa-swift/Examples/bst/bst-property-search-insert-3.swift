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

func insert(_ value: Int, into node: TreeNode?) -> TreeNode {
    guard let node else { return TreeNode(value) }       // an empty spot: the new leaf
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else if value > node.value {
        node.right = insert(value, into: node.right)
    }                                                     // equal: already there, do nothing
    return node
}

// Sideways: the root on the left, the right subtree above it. Tilt your head left to see it.
func draw(_ node: TreeNode?, _ indent: String = "") {
    guard let node else { return }
    draw(node.right, indent + "    ")
    print(indent + String(node.value))
    draw(node.left, indent + "    ")
}

var root: TreeNode? = nil
for value in [50, 30, 70, 20, 40, 60, 80, 35, 30] {
    root = insert(value, into: root)
}
draw(root)
