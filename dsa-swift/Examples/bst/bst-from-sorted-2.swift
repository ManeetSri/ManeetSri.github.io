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

func insert(_ value: Int, into node: TreeNode?) -> TreeNode {
    guard let node else { return TreeNode(value) }
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else if value > node.value {
        node.right = insert(value, into: node.right)
    }
    return node
}

func inorder(_ node: TreeNode?, into values: inout [Int]) {
    guard let node else { return }
    inorder(node.left, into: &values)
    values.append(node.value)
    inorder(node.right, into: &values)
}

func balancedBST(_ values: [Int]) -> TreeNode? {
    func build(_ low: Int, _ high: Int) -> TreeNode? {
        guard low < high else { return nil }
        let mid = low + (high - low) / 2
        return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
    }
    return build(0, values.count)
}

func rebalance(_ root: TreeNode?) -> TreeNode? {
    var values: [Int] = []
    inorder(root, into: &values)
    return balancedBST(values)
}

func height(_ node: TreeNode?) -> Int {
    guard let node else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

var chain: TreeNode? = nil
for value in 1...100 {
    chain = insert(value, into: chain)               // sorted input: a chain
}
let fixed = rebalance(chain)
var check: [Int] = []
inorder(fixed, into: &check)
print("before:", height(chain), "after:", height(fixed), "same values:", check == Array(1...100))
