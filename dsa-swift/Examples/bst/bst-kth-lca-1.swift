// Generated from src/dsa/content/lessons/bst/bst-kth-lca.mdx. Edit the lesson, then run
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

func kthSmallest(_ k: Int, in root: TreeNode?) -> Int? {
    var stack: [TreeNode] = []
    var current = root
    var visited = 0
    while current != nil || !stack.isEmpty {
        while let node = current {                 // slide down the left spine
            stack.append(node)
            current = node.left
        }
        let node = stack.removeLast()              // the next value in sorted order
        visited += 1
        print("  visit \(node.value) (#\(visited))")
        if visited == k {
            return node.value
        }
        current = node.right
    }
    return nil                                     // fewer than k values
}

//            50
//         /      \
//       30        70
//      /  \      /  \
//    20    40  60    80
//         /
//       35
let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
print("k = 3:", kthSmallest(3, in: root) as Any)
print("k = 9:", kthSmallest(9, in: root) as Any)
