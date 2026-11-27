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

func trim(_ node: TreeNode?, to range: ClosedRange<Int>) -> TreeNode? {
    guard let node else { return nil }
    if node.value < range.lowerBound {
        return trim(node.right, to: range)            // node and its left subtree are all too small
    }
    if node.value > range.upperBound {
        return trim(node.left, to: range)             // node and its right subtree are all too big
    }
    node.left = trim(node.left, to: range)
    node.right = trim(node.right, to: range)
    return node
}

func draw(_ node: TreeNode?, _ indent: String = "") {
    guard let node else { return }
    draw(node.right, indent + "    ")
    print(indent + String(node.value))
    draw(node.left, indent + "    ")
}

func sample() -> TreeNode {
    TreeNode(50,
             left: TreeNode(30, left: TreeNode(20), right: TreeNode(40, left: TreeNode(35))),
             right: TreeNode(70, left: TreeNode(60, right: TreeNode(65)), right: TreeNode(80)))
}

print("trim to 33...65:")
draw(trim(sample(), to: 33...65))
print("trim to 55...100:")
draw(trim(sample(), to: 55...100))
