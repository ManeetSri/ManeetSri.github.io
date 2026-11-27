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

func levelOrder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var queue = [root].compactMap { $0 }
    var head = 0
    while head < queue.count {
        let node = queue[head]
        head += 1
        result.append(node.value)
        if let left = node.left { queue.append(left) }
        if let right = node.right { queue.append(right) }
        print("visit \(node.value), queue \(queue[head...].map(\.value))")
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(levelOrder(root))
