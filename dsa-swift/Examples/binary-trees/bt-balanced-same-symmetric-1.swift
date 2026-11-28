// Generated from src/dsa/content/lessons/binary-trees/bt-balanced-same-symmetric.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var heightCalls = 0

func height(_ node: TreeNode?) -> Int {
    heightCalls += 1
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

func isBalancedTopDown(_ node: TreeNode?) -> Bool {
    guard let node else { return true }
    return abs(height(node.left) - height(node.right)) <= 1
        && isBalancedTopDown(node.left)
        && isBalancedTopDown(node.right)
}

var checkedCalls = 0

/// The height of node's subtree, or nil if some subtree inside it is unbalanced
func checkedHeight(_ node: TreeNode?) -> Int? {
    checkedCalls += 1
    guard let node else { return 0 }
    guard let left = checkedHeight(node.left),
          let right = checkedHeight(node.right),
          abs(left - right) <= 1 else { return nil }
    return 1 + max(left, right)
}

func isBalanced(_ root: TreeNode?) -> Bool {
    checkedHeight(root) != nil
}

print(isBalanced(TreeNode.make([1, 2, 3, 4, 5, nil, 6])))
print(isBalanced(TreeNode.make([1, 2, 2, 3, nil, nil, 3, 4, nil, nil, 4])))
print(isBalanced(nil))

let perfect = TreeNode.make(Array(1...16_383))      // 14 full levels
checkedCalls = 0
print(isBalancedTopDown(perfect), "with", heightCalls, "calls to height")
print(isBalanced(perfect), "with", checkedCalls, "calls to checkedHeight")

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
