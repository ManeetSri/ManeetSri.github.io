// Generated from src/dsa/content/lessons/dp-advanced/dpa-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One number per node: "the best for this subtree". Correct, but it calls grandchildren again and again.
var naiveCalls = 0
func robNaive(_ node: TreeNode?) -> Int {
    naiveCalls += 1
    guard let node else { return 0 }
    var takeIt = node.value
    for child in [node.left, node.right] {
        if let child {
            takeIt += robNaive(child.left) + robNaive(child.right)   // grandchildren
        }
    }
    let skipIt = robNaive(node.left) + robNaive(node.right)           // children
    return max(takeIt, skipIt)
}

var pairCalls = 0
func robPair(_ node: TreeNode?) -> (taken: Int, skipped: Int) {
    pairCalls += 1
    guard let node else { return (0, 0) }
    let left = robPair(node.left)
    let right = robPair(node.right)
    return (node.value + left.skipped + right.skipped,
            max(left.taken, left.skipped) + max(right.taken, right.skipped))
}

// A perfect tree with 10 levels: 1,023 nodes, numbered 1, 2, 3, … in the order they're built
func perfect(_ levels: Int, _ next: inout Int) -> TreeNode? {
    if levels == 0 { return nil }
    let node = TreeNode(next)
    next += 1
    node.left = perfect(levels - 1, &next)
    node.right = perfect(levels - 1, &next)
    return node
}
var counter = 1
let tree = perfect(10, &counter)!
let fast = robPair(tree)
print("naive:", robNaive(tree), "with", naiveCalls, "calls")
print("pairs:", max(fast.taken, fast.skipped), "with", pairCalls, "calls")

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
