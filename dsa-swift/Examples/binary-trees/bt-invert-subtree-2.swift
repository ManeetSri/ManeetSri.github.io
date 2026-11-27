// Generated from src/dsa/content/lessons/binary-trees/bt-invert-subtree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0

func isSame(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
    comparisons += 1
    switch (a, b) {
    case (nil, nil):
        return true
    case let (a?, b?):
        return a.value == b.value && isSame(a.left, b.left) && isSame(a.right, b.right)
    default:
        return false
    }
}

func contains(_ pattern: TreeNode?, in tree: TreeNode?) -> Bool {
    guard let pattern else { return true }              // the empty tree is inside every tree
    guard let tree else { return false }
    return isSame(tree, pattern)
        || contains(pattern, in: tree.left)
        || contains(pattern, in: tree.right)
}

let tree = TreeNode.make([7, 2, 9, 1, 5])
print(contains(TreeNode.make([2, 1, 5]), in: tree))
print(contains(TreeNode.make([2, 1]), in: tree))
print(contains(TreeNode.make([9]), in: tree))

// The worst case: 1,023 zeros, and a pattern of 7 zeros whose last leaf is 1
let zeros = TreeNode.make(Array(repeating: 0, count: 1_023))
comparisons = 0
print(contains(TreeNode.make([0, 0, 0, 0, 0, 0, 1]), in: zeros), "after", comparisons, "comparisons")

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
