// Generated from src/dsa/content/lessons/bst/bst-from-sorted.mdx. Edit the lesson, then run
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

func balancedBST(_ values: [Int]) -> TreeNode? {
    func build(_ low: Int, _ high: Int) -> TreeNode? {      // the values at low..<high
        guard low < high else { return nil }
        let mid = low + (high - low) / 2
        return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
    }
    return build(0, values.count)
}

func height(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

// Sideways: the root on the left, the right subtree above it. Tilt your head left to see it.
func draw(_ node: TreeNode?, _ indent: String = "") {
    guard let node else { return }
    draw(node.right, indent + "    ")
    print(indent + String(node.value))
    draw(node.left, indent + "    ")
}

let root = balancedBST(Array(1...10))
draw(root)
print("height:", height(root))
