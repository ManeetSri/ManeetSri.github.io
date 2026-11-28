// Generated from src/dsa/content/lessons/tree-traversals/trav-level-order.mdx. Edit the lesson, then run
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

// Levels down to the nearest leaf, stopping as soon as one is found
func minimumDepth(_ root: TreeNode?) -> Int {
    var level = [root].compactMap { $0 }
    var depth = 0
    while !level.isEmpty {
        depth += 1
        if level.contains(where: { $0.left == nil && $0.right == nil }) {
            return depth
        }
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return 0                                     // the empty tree
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
let lopsided = TreeNode(1, left: TreeNode(2), right: TreeNode(3, right: TreeNode(4, right: TreeNode(5))))
print(minimumDepth(root), minimumDepth(lopsided), minimumDepth(nil))
