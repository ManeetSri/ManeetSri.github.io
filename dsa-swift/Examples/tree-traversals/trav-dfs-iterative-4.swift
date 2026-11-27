// Generated from src/dsa/content/lessons/tree-traversals/trav-dfs-iterative.mdx. Edit the lesson, then run
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

// Every shape of binary tree holding first...last, numbered in inorder
func allTrees(_ first: Int, _ last: Int) -> [TreeNode?] {
    if first > last { return [nil] }
    var trees: [TreeNode?] = []
    for rootValue in first...last {
        for left in allTrees(first, rootValue - 1) {
            for right in allTrees(rootValue + 1, last) {
                trees.append(TreeNode(rootValue, left: left, right: right))
            }
        }
    }
    return trees
}

func recursivePostorder(_ node: TreeNode?, into result: inout [Int]) {
    guard let node else { return }
    recursivePostorder(node.left, into: &result)
    recursivePostorder(node.right, into: &result)
    result.append(node.value)
}

func iterativePostorder(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack: [TreeNode] = []
    var current = root
    var lastVisited: TreeNode? = nil
    while current != nil || !stack.isEmpty {
        while let node = current {
            stack.append(node)
            current = node.left
        }
        let top = stack[stack.count - 1]
        if let right = top.right, right !== lastVisited {
            current = right
        } else {
            result.append(top.value)
            lastVisited = top
            stack.removeLast()
        }
    }
    return result
}

var checked = 0
var mismatches = 0
for size in 0...6 {
    for tree in allTrees(1, size) {
        var expected: [Int] = []
        recursivePostorder(tree, into: &expected)
        if iterativePostorder(tree) != expected { mismatches += 1 }
        checked += 1
    }
}
print("checked \(checked) trees, \(mismatches) mismatches")
