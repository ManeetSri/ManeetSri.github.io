// Generated from src/dsa/content/lessons/tree-traversals/trav-level-order.mdx. Edit the lesson, then run
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

// 1. One queue: count the level, then take exactly that many
func levelsCounting(_ root: TreeNode?) -> [[Int]] {
    var result: [[Int]] = []
    var queue = [root].compactMap { $0 }
    var head = 0
    while head < queue.count {
        let levelSize = queue.count - head           // everything queued now is one level
        var values: [Int] = []
        for _ in 0..<levelSize {
            let node = queue[head]
            head += 1
            values.append(node.value)
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        result.append(values)
    }
    return result
}

// 2. Two arrays: this level, and the next one built from its children
func levelsTwoArrays(_ root: TreeNode?) -> [[Int]] {
    var result: [[Int]] = []
    var level = [root].compactMap { $0 }
    while !level.isEmpty {
        result.append(level.map(\.value))
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return result
}

// 3. Depth-first, carrying the depth: preorder meets each level left to right
func levelsByDepth(_ root: TreeNode?) -> [[Int]] {
    var result: [[Int]] = []
    func walk(_ node: TreeNode?, _ depth: Int) {
        guard let node else { return }
        if depth == result.count { result.append([]) }     // first node on a new level
        result[depth].append(node.value)
        walk(node.left, depth + 1)
        walk(node.right, depth + 1)
    }
    walk(root, 0)
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(levelsCounting(root))
print(levelsTwoArrays(root))
print(levelsByDepth(root))
print(levelsCounting(nil))
