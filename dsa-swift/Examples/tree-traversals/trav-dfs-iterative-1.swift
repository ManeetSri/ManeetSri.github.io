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

func preorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack = [root].compactMap { $0 }
    while let node = stack.popLast() {
        result.append(node.value)
        if let right = node.right { stack.append(right) }      // pushed first, comes off later
        if let left = node.left { stack.append(left) }
        print("visit \(node.value), stack \(stack.map(\.value))")
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(preorder(root))
