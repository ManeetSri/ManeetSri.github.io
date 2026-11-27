// Generated from src/dsa/content/lessons/binary-trees/bt-path-sums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countPaths(in root: TreeNode?, summingTo target: Int) -> Int {
    var seen: [Int: Int] = [0: 1]                       // running sums on the path above: just the empty path
    var count = 0
    func walk(_ node: TreeNode?, _ runningAbove: Int) {
        guard let node else { return }
        let running = runningAbove + node.value
        let found = seen[running - target, default: 0]  // downward paths that end at this node
        count += found
        print("at \(node.value): running \(running), look for \(running - target), found \(found)")
        seen[running, default: 0] += 1                  // arrive
        walk(node.left, running)
        walk(node.right, running)
        seen[running, default: 0] -= 1                  // leave: this sum isn't above the next nodes
    }
    walk(root, 0)
    return count
}

let tree = TreeNode.make([7, 2, 5, 4, -1, nil, 3, 1, nil, 6, 2])
print("total:", countPaths(in: tree, summingTo: 7))

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
