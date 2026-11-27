// Generated from src/dsa/content/lessons/bst/bst-min-max-successor.mdx. Edit the lesson, then run
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

func minimum(_ root: TreeNode?) -> TreeNode? {
    guard var node = root else { return nil }
    while let left = node.left {
        node = left
    }
    return node
}

func maximum(_ root: TreeNode?) -> TreeNode? {
    guard var node = root else { return nil }
    while let right = node.right {
        node = right
    }
    return node
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60, right: TreeNode(65)), right: TreeNode(80)))
print(minimum(root)?.value as Any, maximum(root)?.value as Any)
print(minimum(root.right)?.value as Any)           // the smallest in 50's right subtree
print(minimum(nil)?.value as Any)
