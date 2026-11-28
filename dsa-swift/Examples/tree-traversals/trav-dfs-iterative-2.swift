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
        while let node = current {          // 1. slide down the left edge
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()       // 2. its left subtree is done
        result.append(node.value)
        print("visit \(node.value), waiting \(stack.map(\.value))")
        current = node.right                // 3. now its right subtree
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(inorder(root))
