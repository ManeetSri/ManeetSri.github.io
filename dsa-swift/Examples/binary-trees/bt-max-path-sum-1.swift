// Generated from src/dsa/content/lessons/binary-trees/bt-max-path-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maximumPathSum(_ root: TreeNode) -> Int {
    var best = root.value                               // any single node is a path
    func gain(_ node: TreeNode?) -> Int {
        guard let node else { return 0 }
        let left = max(0, gain(node.left))              // a negative branch is left off
        let right = max(0, gain(node.right))
        let through = node.value + left + right         // the best path bending here
        best = max(best, through)
        print("\(node.value): gains \(left) and \(right), through \(through), returns \(node.value + max(left, right))")
        return node.value + max(left, right)            // a parent can extend only one side
    }
    _ = gain(root)
    return best
}

let tree = TreeNode.make([5, -6, 4, 8, 3, nil, -9, nil, nil, nil, nil, 7, 2])!
print("best:", maximumPathSum(tree))

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
