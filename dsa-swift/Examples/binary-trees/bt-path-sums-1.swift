// Generated from src/dsa/content/lessons/binary-trees/bt-path-sums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hasPathSum(_ node: TreeNode?, _ target: Int) -> Bool {
    guard let node else { return false }
    let remaining = target - node.value
    if node.left == nil && node.right == nil {
        return remaining == 0
    }
    return hasPathSum(node.left, remaining) || hasPathSum(node.right, remaining)
}

func paths(in root: TreeNode?, summingTo target: Int) -> [[Int]] {
    var result: [[Int]] = []
    var path: [Int] = []                                // the values from the root to the current node
    func walk(_ node: TreeNode?, _ remaining: Int) {
        guard let node else { return }
        path.append(node.value)                         // arrive
        let stillNeeded = remaining - node.value
        if node.left == nil && node.right == nil {
            if stillNeeded == 0 {
                result.append(path)                     // stores a copy of path as it is now
            }
        } else {
            walk(node.left, stillNeeded)
            walk(node.right, stillNeeded)
        }
        path.removeLast()                               // leave: backtrack
    }
    walk(root, target)
    return result
}

let tree = TreeNode.make([7, 2, 5, 4, -1, nil, 3, 1, nil, 6, 2])
print(hasPathSum(tree, 14), hasPathSum(tree, 13))
print(paths(in: tree, summingTo: 14))
print(paths(in: tree, summingTo: 15))
print(paths(in: tree, summingTo: 9))

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
