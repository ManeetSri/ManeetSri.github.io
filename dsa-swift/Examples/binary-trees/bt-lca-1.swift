// Generated from src/dsa/content/lessons/binary-trees/bt-lca.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lowestCommonAncestor(_ root: TreeNode?, _ p: TreeNode, _ q: TreeNode) -> TreeNode? {
    guard let root else { return nil }
    if root === p || root === q { return root }
    let left = lowestCommonAncestor(root.left, p, q)
    let right = lowestCommonAncestor(root.right, p, q)
    if left != nil && right != nil { return root }   // p and q are on different sides
    return left ?? right
}

let tree = TreeNode.make([10, 4, 7, 1, 9, nil, 3, nil, nil, 5, 8])!
for (p, q) in [(5, 8), (5, 1), (5, 3), (9, 8), (7, 7)] {
    let answer = lowestCommonAncestor(tree, tree.find(p)!, tree.find(q)!)
    print("LCA of \(p) and \(q):", answer!.value)
}

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    /// The first node holding value, searching level by level, like find in DSAKit
    func find(_ value: Int) -> TreeNode? {
        var queue = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if node.value == value { return node }
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        return nil
    }

    /// Builds a tree from its level order, with nil for a missing child, like TreeNode.make in DSAKit
    static func make(_ levelOrder: [Int?]) -> TreeNode? {
        guard let first = levelOrder.first, let rootValue = first else { return nil }
        let root = TreeNode(rootValue)
        var parents = [root]
        var head = 0
        var index = 1
        while index < levelOrder.count && head < parents.count {
            let parent = parents[head]
            head += 1
            if let value = levelOrder[index] {
                parent.left = TreeNode(value)
                parents.append(parent.left!)
            }
            index += 1
            if index < levelOrder.count, let value = levelOrder[index] {
                parent.right = TreeNode(value)
                parents.append(parent.right!)
            }
            index += 1
        }
        return root
    }
}
