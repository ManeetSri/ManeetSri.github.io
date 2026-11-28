// Generated from src/dsa/content/lessons/tree-traversals/trav-vertical-boundary.mdx. Edit the lesson, then run
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

func isLeaf(_ node: TreeNode) -> Bool {
    node.left == nil && node.right == nil
}

func leaves(_ node: TreeNode?, into result: inout [Int]) {
    guard let node else { return }
    if isLeaf(node) { result.append(node.value) }
    leaves(node.left, into: &result)
    leaves(node.right, into: &result)
}

func boundary(_ root: TreeNode?) -> [Int] {
    guard let root else { return [] }
    if isLeaf(root) { return [root.value] }
    var result = [root.value]

    var next = root.left                               // the left edge, going down
    while let node = next, !isLeaf(node) {
        result.append(node.value)
        next = node.left ?? node.right
    }

    leaves(root, into: &result)                        // the bottom, left to right

    var rightEdge: [Int] = []                          // the right edge, collected going down...
    next = root.right
    while let node = next, !isLeaf(node) {
        rightEdge.append(node.value)
        next = node.right ?? node.left
    }
    return result + rightEdge.reversed()               // ...and added coming back up
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(boundary(root))
print(boundary(TreeNode(5)))
print(boundary(TreeNode(1, right: TreeNode(2, left: TreeNode(3), right: TreeNode(4)))))
print(boundary(TreeNode(1, left: TreeNode(2, right: TreeNode(4, left: TreeNode(5), right: TreeNode(6))), right: TreeNode(3))))
