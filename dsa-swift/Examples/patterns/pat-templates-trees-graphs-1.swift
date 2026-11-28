// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Tree DFS in both directions: answers flowing up, and context flowing down
final class TreeNode {
    let value: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ value: Int) { self.value = value }
}

// Build a tree from a level-order list with nil gaps
func makeTree(_ values: [Int?]) -> TreeNode? {
    guard let first = values.first, let rootValue = first else { return nil }
    let root = TreeNode(rootValue)
    var queue = [root]
    var head = 0
    var i = 1
    while i < values.count {
        let parent = queue[head]
        head += 1
        if let value = values[i] {
            parent.left = TreeNode(value)
            queue.append(parent.left!)
        }
        if i + 1 < values.count, let value = values[i + 1] {
            parent.right = TreeNode(value)
            queue.append(parent.right!)
        }
        i += 2
    }
    return root
}

// Up: each call returns its subtree's height; the best path through any node is tracked on the side
func diameter(_ root: TreeNode?) -> Int {
    var best = 0                                  // the longest path, in edges, seen so far
    func height(_ node: TreeNode?) -> Int {
        guard let node else { return 0 }
        let left = height(node.left)
        let right = height(node.right)
        best = max(best, left + right)            // the path that bends at this node
        return 1 + max(left, right)               // what the parent needs from this subtree
    }
    _ = height(root)
    return best
}

// Down: each call receives what the path from the root knows (here, the largest value on it)
func goodNodes(_ root: TreeNode?) -> Int {
    func count(_ node: TreeNode?, _ largestAbove: Int) -> Int {
        guard let node else { return 0 }
        let good = node.value >= largestAbove ? 1 : 0
        let largest = max(largestAbove, node.value)
        return good + count(node.left, largest) + count(node.right, largest)
    }
    return count(root, Int.min)
}

let tree = makeTree([3, 1, 4, 3, nil, 1, 5])
print(diameter(tree), goodNodes(tree))
print(diameter(makeTree([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])), goodNodes(makeTree([2, 2, 1])))
