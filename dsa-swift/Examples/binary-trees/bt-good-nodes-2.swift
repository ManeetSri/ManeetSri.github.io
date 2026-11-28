// Generated from src/dsa/content/lessons/binary-trees/bt-good-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pathNumberSum(_ root: TreeNode?) -> Int {
    func sum(_ node: TreeNode?, spelledAbove: Int) -> Int {
        guard let node else { return 0 }
        let number = spelledAbove * 10 + node.value     // add this digit on the right
        if node.left == nil && node.right == nil {
            return number                               // a leaf completes one number
        }
        return sum(node.left, spelledAbove: number) + sum(node.right, spelledAbove: number)
    }
    return sum(root, spelledAbove: 0)
}

print(pathNumberSum(TreeNode.make([3, 9, 0, nil, nil, 5, 1])))
print(pathNumberSum(TreeNode.make([1, 2])))
print(pathNumberSum(TreeNode.make([0, 1, 0])))

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
