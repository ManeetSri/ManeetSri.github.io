// Generated from src/dsa/content/lessons/tree-traversals/trav-zigzag-views.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

func topAndBottom(_ root: TreeNode?) -> (top: [Int], bottom: [Int]) {
    guard let root else { return ([], []) }
    var top: [Int: Int] = [:]                    // column -> value
    var bottom: [Int: Int] = [:]
    var queue: [(node: TreeNode, column: Int)] = [(root, 0)]
    var head = 0
    while head < queue.count {
        let (node, column) = queue[head]
        head += 1
        if top[column] == nil {
            top[column] = node.value             // the first, so the highest, in this column
        }
        bottom[column] = node.value              // the last so far, so the lowest
        if let left = node.left { queue.append((left, column - 1)) }
        if let right = node.right { queue.append((right, column + 1)) }
    }
    let columns = top.keys.sorted()              // dictionary order is random: sort the keys
    return (columns.map { top[$0]! }, columns.map { bottom[$0]! })
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
let views = topAndBottom(root)
print("top:   ", views.top)
print("bottom:", views.bottom)

// 4 and 5 share column 0 and level 2: a tie
let tied = TreeNode(1, left: TreeNode(2, right: TreeNode(4)), right: TreeNode(3, left: TreeNode(5)))
print("tie, bottom:", topAndBottom(tied).bottom)
