// Generated from src/dsa/content/lessons/binary-trees/bt-invert-subtree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

@discardableResult
func invert(_ node: TreeNode?) -> TreeNode? {
    guard let node else { return nil }
    (node.left, node.right) = (node.right, node.left)   // swap the two children
    invert(node.left)
    invert(node.right)
    return node
}

let tree = TreeNode.make([4, 2, 7, 1, 3, nil, 9])
print(invert(tree)!)
invert(tree)
print(tree!)

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode: CustomStringConvertible {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    /// The tree in level order, such as [4, 2, 7, nil, 3], like DSAKit's description
    var description: String {
        var result: [String] = []
        var queue: [TreeNode?] = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            result.append(node.map { String($0.value) } ?? "nil")
            if let node {
                queue.append(node.left)
                queue.append(node.right)
            }
        }
        while result.last == "nil" {
            result.removeLast()
        }
        return "[" + result.joined(separator: ", ") + "]"
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
