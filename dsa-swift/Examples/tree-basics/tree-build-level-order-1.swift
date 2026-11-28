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

func text(_ value: Int?) -> String {
    value.map(String.init) ?? "nil"
}

func build(_ levelOrder: [Int?]) -> TreeNode? {
    guard let first = levelOrder.first, let rootValue = first else { return nil }
    let root = TreeNode(rootValue)
    var queue = [root]                       // nodes waiting for their children
    var head = 0
    var index = 1                            // the next entry to read
    while index < levelOrder.count && head < queue.count {
        let parent = queue[head]
        head += 1
        let leftEntry = levelOrder[index]
        let rightEntry = index + 1 < levelOrder.count ? levelOrder[index + 1] : nil
        if let value = leftEntry {
            parent.left = TreeNode(value)
            queue.append(parent.left!)
        }
        if let value = rightEntry {
            parent.right = TreeNode(value)
            queue.append(parent.right!)
        }
        index += 2
        let waiting = queue[head...].map { String($0.value) }.joined(separator: ", ")
        print("\(parent.value) gets \(text(leftEntry)) and \(text(rightEntry)); waiting: [\(waiting)]")
    }
    return root
}

let root = build([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])!
print("root \(root.value), 3's right child \(root.right!.right!.value), 5's left child \(root.left!.right!.left!.value)")
