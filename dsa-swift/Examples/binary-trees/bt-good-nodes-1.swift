// Generated from src/dsa/content/lessons/binary-trees/bt-good-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func goodNodeCount(_ root: TreeNode?) -> Int {
    func count(_ node: TreeNode?, highestAbove: Int) -> Int {
        guard let node else { return 0 }
        let good = node.value >= highestAbove ? 1 : 0
        let highest = max(highestAbove, node.value)     // what this node's children see above them
        return good + count(node.left, highestAbove: highest) + count(node.right, highestAbove: highest)
    }
    return count(root, highestAbove: Int.min)           // nothing above the root
}

print(goodNodeCount(TreeNode.make([4, 2, 6, 5, 1, 6, 3, nil, nil, 7])))
print(goodNodeCount(TreeNode.make([9, 8, 7, 6, 5])))
print(goodNodeCount(TreeNode.make([1, nil, 2, nil, 3])))
print(goodNodeCount(nil))

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
