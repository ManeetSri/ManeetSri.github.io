// Generated from src/dsa/content/lessons/tree-traversals/trav-zigzag-views.mdx. Edit the lesson, then run
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

func rightViewByLevels(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var level = [root].compactMap { $0 }
    while let last = level.last {
        result.append(last.value)                       // the rightmost on this level
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

func view(_ root: TreeNode?, fromRight: Bool) -> [Int] {
    var result: [Int] = []
    func walk(_ node: TreeNode?, _ depth: Int) {
        guard let node else { return }
        if depth == result.count {
            result.append(node.value)                   // first node reached on this depth
        }
        let (near, far) = fromRight ? (node.right, node.left) : (node.left, node.right)
        walk(near, depth + 1)
        walk(far, depth + 1)
    }
    walk(root, 0)
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print("right, by levels:", rightViewByLevels(root))
print("right, by depth: ", view(root, fromRight: true))
print("left, by depth:  ", view(root, fromRight: false))
