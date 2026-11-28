// Generated from src/dsa/content/lessons/bst/bst-recover-trim.mdx. Edit the lesson, then run
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

func recover(_ root: TreeNode?) {
    var first: TreeNode? = nil
    var second: TreeNode? = nil
    var previous: TreeNode? = nil
    var stack: [TreeNode] = []
    var current = root
    while current != nil || !stack.isEmpty {
        while let node = current {
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()
        if let previous, previous.value > node.value {      // a drop
            if first == nil {
                first = previous
            }
            second = node
        }
        previous = node
        current = node.right
    }
    if let first, let second {
        print("swapping \(first.value) and \(second.value) back")
        (first.value, second.value) = (second.value, first.value)
    }
}

func inorder(_ node: TreeNode?) -> [Int] {
    guard let node else { return [] }
    return inorder(node.left) + [node.value] + inorder(node.right)
}

// 50, 30, 70, 20, 40, 60, 80 with 30 and 40 swapped (neighbours in sorted order)
let near = TreeNode(50, left: TreeNode(40, left: TreeNode(20), right: TreeNode(30)),
                        right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
print(inorder(near))
recover(near)
print(inorder(near))

// The same tree with 20 and 70 swapped (far apart)
let far = TreeNode(50, left: TreeNode(30, left: TreeNode(70), right: TreeNode(40)),
                       right: TreeNode(20, left: TreeNode(60), right: TreeNode(80)))
print(inorder(far))
recover(far)
print(inorder(far))
