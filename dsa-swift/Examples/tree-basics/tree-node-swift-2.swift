// Generated from src/dsa/content/lessons/tree-basics/tree-node-swift.mdx. Edit the lesson, then run
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

let root = TreeNode(5, left: TreeNode(2), right: TreeNode(8))

// Two references to the same node: a change through one is seen through the other
let node = root.left!
node.value = 3
print("root.left now holds", root.left!.value)
print("same node?", node === root.left!)

// Rewire the tree in place, even though root is a let
root.right!.right = TreeNode(9)
root.left = nil
print("right child's right:", root.right!.right!.value, "| left is nil:", root.left == nil)

// The same node placed in two spots is ONE node
let shared = TreeNode(7)
let odd = TreeNode(0, left: shared, right: shared)
shared.value = 70
print("left \(odd.left!.value), right \(odd.right!.value)")
