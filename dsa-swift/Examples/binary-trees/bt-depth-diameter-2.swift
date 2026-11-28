// Generated from src/dsa/content/lessons/binary-trees/bt-depth-diameter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func wrongMinDepth(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    return 1 + min(wrongMinDepth(node.left), wrongMinDepth(node.right))
}

func minDepth(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    switch (node.left, node.right) {
    case (nil, nil):
        return 1                                        // a leaf
    case (let child?, nil), (nil, let child?):
        return 1 + minDepth(child)                      // only one way down
    case (let left?, let right?):
        return 1 + min(minDepth(left), minDepth(right))
    }
}

// 1 has only a right child, 2, and 2 has a leaf, 3
let lopsided = TreeNode(1, right: TreeNode(2, right: TreeNode(3)))
print(wrongMinDepth(lopsided), minDepth(lopsided))

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

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
