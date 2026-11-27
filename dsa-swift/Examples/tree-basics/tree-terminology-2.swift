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

func printDepths(_ node: TreeNode?, depth: Int) {
    guard let node else { return }
    let kind = node.left == nil && node.right == nil ? "leaf" : "internal"
    print(String(repeating: "  ", count: depth) + "\(node.value): depth \(depth), \(kind)")
    printDepths(node.left, depth: depth + 1)
    printDepths(node.right, depth: depth + 1)
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
printDepths(root, depth: 0)
