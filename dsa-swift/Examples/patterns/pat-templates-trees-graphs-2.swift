// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Level-order BFS one level at a time, and walking a BST by its ordering
final class TreeNode {
    let value: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ value: Int, _ left: TreeNode? = nil, _ right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

// Level by level: at the top of each round, the queue holds exactly one whole level
func levels(_ root: TreeNode?) -> [[Int]] {
    guard let root else { return [] }
    var result: [[Int]] = []
    var level = [root]
    while !level.isEmpty {
        result.append(level.map { $0.value })
        var next: [TreeNode] = []
        for node in level {
            if let left = node.left { next.append(left) }
            if let right = node.right { next.append(right) }
        }
        level = next
    }
    return result
}

// BST: smaller values go left, so one comparison discards a whole subtree
func lowestCommonAncestor(_ root: TreeNode?, _ p: Int, _ q: Int) -> Int? {
    var node = root
    while let current = node {
        if p < current.value && q < current.value {
            node = current.left                   // both in the left subtree
        } else if p > current.value && q > current.value {
            node = current.right                  // both in the right subtree
        } else {
            return current.value                  // they split here (or one of them is here)
        }
    }
    return nil
}

// Validate: every node must fit the range its ancestors allow
func isValidBST(_ node: TreeNode?, _ low: Int = Int.min, _ high: Int = Int.max) -> Bool {
    guard let node else { return true }
    guard low < node.value, node.value < high else { return false }
    return isValidBST(node.left, low, node.value) && isValidBST(node.right, node.value, high)
}

//        8
//      /   \
//     3     10
//    / \      \
//   1   6      14
//      / \
//     4   7
let bst = TreeNode(8, TreeNode(3, TreeNode(1), TreeNode(6, TreeNode(4), TreeNode(7))), TreeNode(10, nil, TreeNode(14)))
print(levels(bst))
print(lowestCommonAncestor(bst, 4, 7)!, lowestCommonAncestor(bst, 4, 14)!, lowestCommonAncestor(bst, 3, 7)!)
print(isValidBST(bst), isValidBST(TreeNode(8, TreeNode(3, nil, TreeNode(9)), nil)))
