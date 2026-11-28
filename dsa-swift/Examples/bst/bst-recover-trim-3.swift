// Generated from src/dsa/content/lessons/bst/bst-recover-trim.mdx. Edit the lesson, then run
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

func greaterSumTree(_ root: TreeNode?) {
    var total = 0
    func walk(_ node: TreeNode?) {
        guard let node else { return }
        walk(node.right)                              // bigger values first
        total += node.value
        node.value = total
        walk(node.left)
    }
    walk(root)
}

func inorder(_ node: TreeNode?) -> [Int] {
    guard let node else { return [] }
    return inorder(node.left) + [node.value] + inorder(node.right)
}

let root = TreeNode(4, left: TreeNode(2, left: TreeNode(1), right: TreeNode(3)),
                       right: TreeNode(6, left: TreeNode(5), right: TreeNode(7)))
print(inorder(root))
greaterSumTree(root)
print(inorder(root))
print(root.value)
