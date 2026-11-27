// Generated from src/dsa/content/lessons/binary-trees/bt-construct.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fromPreorder(_ preorder: [Int], inorder: [Int]) -> TreeNode? {
    var position: [Int: Int] = [:]
    for (index, value) in inorder.enumerated() {
        position[value] = index
    }
    var next = 0                                        // preorder[next] is the next root to place
    func build(_ low: Int, _ high: Int) -> TreeNode? {  // the subtree whose inorder is inorder[low..<high]
        guard low < high else { return nil }
        let node = TreeNode(preorder[next])
        next += 1
        let middle = position[node.value]!
        node.left = build(low, middle)                  // the left subtree's values come next in preorder
        node.right = build(middle + 1, high)
        return node
    }
    return build(0, inorder.count)
}

func fromPostorder(_ postorder: [Int], inorder: [Int]) -> TreeNode? {
    var position: [Int: Int] = [:]
    for (index, value) in inorder.enumerated() {
        position[value] = index
    }
    var next = postorder.count - 1                      // walk the postorder backwards
    func build(_ low: Int, _ high: Int) -> TreeNode? {
        guard low < high else { return nil }
        let node = TreeNode(postorder[next])
        next -= 1
        let middle = position[node.value]!
        node.right = build(middle + 1, high)            // backwards, the right subtree comes first
        node.left = build(low, middle)
        return node
    }
    return build(0, inorder.count)
}

let inorder = [5, 3, 8, 1, 7, 9, 2]
print(fromPreorder([7, 3, 5, 1, 8, 9, 2], inorder: inorder)!)
print(fromPostorder([5, 8, 1, 3, 2, 9, 7], inorder: inorder)!)
print(fromPreorder([1, 2], inorder: [2, 1])!, fromPreorder([1, 2], inorder: [1, 2])!)

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode: CustomStringConvertible {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    /// The tree in level order, such as [4, 2, 7, nil, 3], like DSAKit's description
    var description: String {
        var result: [String] = []
        var queue: [TreeNode?] = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            result.append(node.map { String($0.value) } ?? "nil")
            if let node {
                queue.append(node.left)
                queue.append(node.right)
            }
        }
        while result.last == "nil" {
            result.removeLast()
        }
        return "[" + result.joined(separator: ", ") + "]"
    }
}
