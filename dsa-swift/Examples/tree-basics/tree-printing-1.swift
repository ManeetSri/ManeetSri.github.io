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

func printLevels(_ root: TreeNode?) {
    var level = [root].compactMap { $0 }
    while !level.isEmpty {
        print(level.map { String($0.value) }.joined(separator: " "))
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
printLevels(root)
