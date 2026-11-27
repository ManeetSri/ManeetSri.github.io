// Generated from src/dsa/content/lessons/bst/bst-validate.mdx. Edit the lesson, then run
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

func isValidInorder(_ root: TreeNode?) -> Bool {
    var stack: [TreeNode] = []
    var current = root
    var previous: Int? = nil                       // optional again: no fake starting value
    while current != nil || !stack.isEmpty {
        while let node = current {
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()
        print("visit \(node.value)")
        if let previous, node.value <= previous {
            return false
        }
        previous = node.value
        current = node.right
    }
    return true
}

let tricky = TreeNode(10, left: TreeNode(5), right: TreeNode(15, left: TreeNode(6), right: TreeNode(20)))
print(isValidInorder(tricky))
