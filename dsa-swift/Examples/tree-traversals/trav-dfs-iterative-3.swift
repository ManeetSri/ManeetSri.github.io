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

// 1. Node, right, left, then reversed: left, right, node
func postorderReversed(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack = [root].compactMap { $0 }
    while let node = stack.popLast() {
        result.append(node.value)
        if let left = node.left { stack.append(left) }
        if let right = node.right { stack.append(right) }
    }
    return result.reversed()
}

// 2. Peek: go right if the right subtree isn't done yet, otherwise visit
func postorderLastVisited(_ root: TreeNode?) -> [Int] {
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
            current = right                       // its right subtree hasn't been done
        } else {
            result.append(top.value)              // both subtrees done
            lastVisited = top
            stack.removeLast()
        }
    }
    return result
}

// 3. Each node goes on twice: once to expand it, once (ready) to visit it
func postorderReady(_ root: TreeNode?) -> [Int] {
    var result: [Int] = []
    var stack: [(node: TreeNode, ready: Bool)] = root.map { [($0, false)] } ?? []
    while let (node, ready) = stack.popLast() {
        if ready {
            result.append(node.value)
            continue
        }
        stack.append((node, true))                // comes off after both children
        if let right = node.right { stack.append((right, false)) }
        if let left = node.left { stack.append((left, false)) }
    }
    return result
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(postorderReversed(root))
print(postorderLastVisited(root))
print(postorderReady(root))
