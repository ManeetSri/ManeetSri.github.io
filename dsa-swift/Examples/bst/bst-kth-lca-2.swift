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

func lowestCommonAncestor(_ p: Int, _ q: Int, in root: TreeNode?) -> TreeNode? {
    var current = root
    while let node = current {
        if p < node.value && q < node.value {
            current = node.left
        } else if p > node.value && q > node.value {
            current = node.right
        } else {
            return node                            // they split here, or one of them is here
        }
    }
    return nil
}

let root = TreeNode(50,
                    left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
                    right: TreeNode(70, left: TreeNode(60), right: TreeNode(80)))
for (p, q) in [(20, 35), (35, 80), (60, 80), (30, 35), (40, 40)] {
    print("LCA(\(p), \(q)) =", lowestCommonAncestor(p, q, in: root)!.value)
}
