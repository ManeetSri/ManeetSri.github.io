// Generated from src/dsa/content/lessons/tree-traversals/trav-dfs-iterative.mdx. Edit the lesson, then run
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

func inorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack: [TreeNode] = []
    var current = root
    while current != nil || !stack.isEmpty {
        while let node = current {
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()
        result.append(node.value)
        current = node.right
    }
    return result
}

// A chain 100,000 nodes deep: every node is the left child of the one before
let root = TreeNode(1)
var bottom = root
for value in 2...100_000 {
    let next = TreeNode(value)
    bottom.left = next
    bottom = next
}
let values = inorder(root)
print(values.count, "values, first \(values.first!), last \(values.last!)")
