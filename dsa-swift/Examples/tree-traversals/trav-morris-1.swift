// Generated from src/dsa/content/lessons/tree-traversals/trav-morris.mdx. Edit the lesson, then run
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

func morrisInorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var current = root
    while let node = current {
        guard let left = node.left else {
            result.append(node.value)            // 1. nothing on the left: visit, go right
            print("visit \(node.value)")
            current = node.right
            continue
        }
        var predecessor = left                   // 2. rightmost node of the left subtree
        while let next = predecessor.right, next !== node {
            predecessor = next
        }
        if predecessor.right == nil {
            predecessor.right = node             // 3. first arrival: leave a thread back
            print("thread \(predecessor.value) -> \(node.value)")
            current = left
        } else {
            predecessor.right = nil              // 4. back via the thread: tidy up, visit
            print("unthread \(predecessor.value) -> \(node.value), visit \(node.value)")
            result.append(node.value)
            current = node.right
        }
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(morrisInorder(root))
