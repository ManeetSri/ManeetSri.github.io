// Generated from src/dsa/content/lessons/tree-basics/tree-terminology.mdx. Edit the lesson, then run
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

// The number of nodes: the root, plus everything in each subtree
func size(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    return 1 + size(node.left) + size(node.right)
}

// The number of levels: the root's level, plus the taller subtree
func height(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

// A leaf counts 1; anything else adds up its subtrees
func leaves(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    if node.left == nil && node.right == nil { return 1 }
    return leaves(node.left) + leaves(node.right)
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))

print("size \(size(root)), height \(height(root)), leaves \(leaves(root))")
print("subtree at 2: size \(size(root.left)), height \(height(root.left))")
print("empty tree: size \(size(nil)), height \(height(nil))")
