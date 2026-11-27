// Generated from src/dsa/content/lessons/tree-basics/tree-printing.mdx. Edit the lesson, then run
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

func draw(_ node: TreeNode, prefix: String = "", connector: String = "",
          above: String = "", below: String = "") {
    if let right = node.right {
        draw(right, prefix: prefix + above, connector: "┌── ", above: "    ", below: "│   ")
    }
    print(prefix + connector + String(node.value))
    if let left = node.left {
        draw(left, prefix: prefix + below, connector: "└── ", above: "│   ", below: "    ")
    }
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
draw(root)
print()
draw(TreeNode(100, left: TreeNode(7), right: TreeNode(2500, left: TreeNode(3), right: TreeNode(41))))
