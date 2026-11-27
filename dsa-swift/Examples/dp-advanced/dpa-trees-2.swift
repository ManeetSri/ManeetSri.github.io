// Generated from src/dsa/content/lessons/dp-advanced/dpa-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// House robber on a tree: every node returns two answers for its subtree
func robTree(_ node: TreeNode?) -> (taken: Int, skipped: Int) {
    guard let node else { return (0, 0) }                  // an empty subtree is worth nothing
    let left = robTree(node.left)
    let right = robTree(node.right)
    let taken = node.value + left.skipped + right.skipped   // take it: both children must be skipped
    let skipped = max(left.taken, left.skipped) + max(right.taken, right.skipped)  // skip it: children are free
    print("\(node.value): taken \(taken), skipped \(skipped)")
    return (taken, skipped)
}

let street = TreeNode.make([6, 4, 9, 7, 2, nil, 1, nil, nil, 5, 8])!
let answer = robTree(street)
print("best:", max(answer.taken, answer.skipped))

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
