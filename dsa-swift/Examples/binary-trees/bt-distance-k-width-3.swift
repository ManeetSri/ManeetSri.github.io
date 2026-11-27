// Generated from src/dsa/content/lessons/binary-trees/bt-distance-k-width.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maximumWidth(_ root: TreeNode?) -> Int {
    guard let root else { return 0 }
    var level: [(node: TreeNode, place: Int)] = [(root, 0)]
    var widest = 0
    while let first = level.first, let last = level.last {
        widest = max(widest, last.place - first.place + 1)
        var below: [(node: TreeNode, place: Int)] = []
        for (node, place) in level {
            let offset = place - first.place            // renormalise: this level now starts at 0
            if let left = node.left { below.append((left, 2 * offset)) }
            if let right = node.right { below.append((right, 2 * offset + 1)) }
        }
        level = below
    }
    return widest
}

print(maximumWidth(TreeNode.make([1, 2, 3, 4, nil, nil, 5])))
print(maximumWidth(TreeNode.make([7, 3, 9, 1, 5, nil, 12, nil, nil, 4, 6])))

// A chain of 200 right children, then two leaves at the bottom
var chainTop = TreeNode(0, left: TreeNode(-1), right: TreeNode(-2))
for value in 1...200 {
    chainTop = TreeNode(value, right: chainTop)
}
print(maximumWidth(chainTop))

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
