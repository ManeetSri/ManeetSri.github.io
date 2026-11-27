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

func printSideways(_ node: TreeNode?, depth: Int = 0) {
    guard let node else { return }
    printSideways(node.right, depth: depth + 1)       // the right subtree goes above
    print(String(repeating: "    ", count: depth) + String(node.value))
    printSideways(node.left, depth: depth + 1)        // the left subtree goes below
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
printSideways(root)
