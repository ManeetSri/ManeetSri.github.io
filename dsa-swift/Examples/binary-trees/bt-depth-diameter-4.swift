// Generated from src/dsa/content/lessons/binary-trees/bt-depth-diameter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func diameter(_ root: TreeNode?) -> Int {
    var best = 0
    func height(_ node: TreeNode?) -> Int {
        guard let node else { return 0 }
        let left = height(node.left)
        let right = height(node.right)
        best = max(best, left + right)       // the longest path through node, in edges
        return 1 + max(left, right)
    }
    _ = height(root)
    return best
}

print(diameter(TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])))
print(diameter(TreeNode.make([1, 2, nil, 3, 4, 5, nil, nil, 6])))
print(diameter(TreeNode.make([8])))
print(diameter(nil))

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
