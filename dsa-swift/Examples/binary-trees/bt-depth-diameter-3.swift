// Generated from src/dsa/content/lessons/binary-trees/bt-depth-diameter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var heightCalls = 0

func height(_ node: TreeNode?) -> Int {
    heightCalls += 1
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

func slowDiameter(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    let bendingHere = height(node.left) + height(node.right)
    return max(bendingHere, slowDiameter(node.left), slowDiameter(node.right))
}

print(slowDiameter(TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])))
print(slowDiameter(TreeNode.make([1, 2, nil, 3, 4, 5, nil, nil, 6])))

// A chain of 1,000 nodes, each the left child of the next
var chain: TreeNode? = nil
for value in 1...1_000 {
    chain = TreeNode(value, left: chain)
}
heightCalls = 0
print(slowDiameter(chain), "after", heightCalls, "calls to height")

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
