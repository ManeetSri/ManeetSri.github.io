// Generated from src/dsa/content/lessons/binary-trees/bt-flatten-next.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func flatten(_ root: TreeNode?) {
    var current = root
    while let node = current {
        if let left = node.left {
            var last = left                             // the end of the left subtree's preorder
            while let next = last.right {
                last = next
            }
            last.right = node.right                     // right subtree goes after the left subtree
            node.right = left                           // left subtree goes right after node
            node.left = nil
        }
        current = node.right
    }
}

func chain(_ root: TreeNode?) -> [Int] {
    var values: [Int] = []
    var node = root
    while let current = node {
        values.append(current.value)
        node = current.right
    }
    return values
}

let tree = TreeNode.make([1, 2, 6, 3, 4, nil, 7, nil, nil, 5])
flatten(tree)
print(chain(tree))
print(tree!.left == nil, tree!.right!.left == nil)

let leaning = TreeNode(3, left: TreeNode(2, left: TreeNode(1)))
flatten(leaning)
print(chain(leaning))

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
