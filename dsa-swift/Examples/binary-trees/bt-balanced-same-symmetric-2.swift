// Generated from src/dsa/content/lessons/binary-trees/bt-balanced-same-symmetric.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isSame(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
    switch (a, b) {
    case (nil, nil):
        return true                                     // both empty
    case let (a?, b?):
        return a.value == b.value && isSame(a.left, b.left) && isSame(a.right, b.right)
    default:
        return false                                    // one is empty and the other isn't
    }
}

let first = TreeNode.make([1, 2, 3])
let second = TreeNode.make([1, 2, 3])
print(isSame(first, second), first === second)
print(isSame(TreeNode.make([1, 2]), TreeNode.make([1, nil, 2])))
print(isSame(nil, nil))

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
