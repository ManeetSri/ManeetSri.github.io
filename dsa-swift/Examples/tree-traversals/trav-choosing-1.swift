// Generated from src/dsa/content/lessons/tree-traversals/trav-choosing.mdx. Edit the lesson, then run
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

func bottomLeftByLevels(_ root: TreeNode) -> Int {
    var level = [root]
    var answer = root.value
    while !level.isEmpty {
        answer = level[0].value                          // leftmost on this level
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return answer
}

func bottomLeftByDepth(_ root: TreeNode) -> Int {
    var deepest = -1
    var answer = root.value
    func walk(_ node: TreeNode?, _ depth: Int) {
        guard let node else { return }
        if depth > deepest {                             // first node seen at a new depth
            deepest = depth
            answer = node.value
        }
        walk(node.left, depth + 1)
        walk(node.right, depth + 1)
    }
    walk(root, 0)
    return answer
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
let other = TreeNode(1, left: TreeNode(2), right: TreeNode(3, left: TreeNode(5), right: TreeNode(6)))
print(bottomLeftByLevels(root), bottomLeftByDepth(root))
print(bottomLeftByLevels(other), bottomLeftByDepth(other))
