// Generated from src/dsa/content/lessons/tree-basics/tree-build-level-order.mdx. Edit the lesson, then run
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

func levelOrder(_ root: TreeNode?) -> [Int?] {
    guard let root else { return [] }
    var result: [Int?] = []
    var queue: [TreeNode?] = [root]
    var head = 0
    while head < queue.count {
        let node = queue[head]
        head += 1
        if let node {
            result.append(node.value)
            queue.append(node.left)
            queue.append(node.right)
        } else {
            result.append(nil)
        }
    }
    while let last = result.last, last == nil {
        result.removeLast()
    }
    return result
}

func text(_ entries: [Int?]) -> String {
    "[" + entries.map { $0.map(String.init) ?? "nil" }.joined(separator: ", ") + "]"
}

let chain = TreeNode(1, right: TreeNode(2, right: TreeNode(3)))
let example = TreeNode(1,
                       left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                       right: TreeNode(3, right: TreeNode(6)))
print(text(levelOrder(chain)))
print(text(levelOrder(example)))
print(levelOrder(TreeNode(8, left: TreeNode(4))))
