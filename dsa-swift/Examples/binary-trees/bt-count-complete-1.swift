// Generated from src/dsa/content/lessons/binary-trees/bt-count-complete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var steps = 0                                           // nodes touched, to compare the two methods

func countAll(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    steps += 1
    return 1 + countAll(node.left) + countAll(node.right)
}

func countComplete(_ root: TreeNode?) -> Int {
    guard let root else { return 0 }
    var leftLevels = 0
    var node: TreeNode? = root
    while let current = node {                          // down the left edge
        steps += 1
        leftLevels += 1
        node = current.left
    }
    var rightLevels = 0
    node = root
    while let current = node {                          // down the right edge
        steps += 1
        rightLevels += 1
        node = current.right
    }
    if leftLevels == rightLevels {
        return (1 << leftLevels) - 1                    // perfect: 2^h − 1 nodes
    }
    return 1 + countComplete(root.left) + countComplete(root.right)
}

let small = TreeNode.make(Array(1...10))
print(countAll(small), countComplete(small))

let big = TreeNode.make(Array(1...100_000))
steps = 0
print(countAll(big), "after", steps, "steps")
steps = 0
print(countComplete(big), "after", steps, "steps")

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
