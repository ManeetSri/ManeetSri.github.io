// The node every binary-tree problem shares (Part V). Problems take and return `TreeNode?`: `nil` is the
// empty tree, and any node is the root of the subtree below it.
//
// Like ListNode it's a class: a node refers to its children, and several references (a parent, a
// pointer in a traversal) often need to reach the same node.

/// One node of a binary tree of Ints.
public final class TreeNode {
    /// The value stored in this node.
    public var value: Int

    /// The root of the left subtree, or nil if there isn't one.
    public var left: TreeNode?

    /// The root of the right subtree, or nil if there isn't one.
    public var right: TreeNode?

    /// A node holding `value` with the given children. O(1).
    public init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    // Releasing a node releases its children, which release theirs, and so on: one nested call per
    // level. A degenerate tree (a "linked list" of 100,000 nodes, say) would overflow the stack, so
    // this unhooks the children with a loop instead. Subtrees still used elsewhere are left alone.
    deinit {
        var pending: [TreeNode] = []
        if let left { pending.append(left) }
        if let right { pending.append(right) }
        left = nil
        right = nil
        while var node = pending.popLast() {
            guard isKnownUniquelyReferenced(&node) else { continue }
            if let child = node.left {
                pending.append(child)
                node.left = nil
            }
            if let child = node.right {
                pending.append(child)
                node.right = nil
            }
        }
    }

    /// Builds a tree from its level order, with `nil` where a child is missing, and returns the root:
    /// `[3, 9, 20, nil, nil, 15, 7]` is 3 with children 9 and 20, and 20 has children 15 and 7.
    /// Missing nodes have no entries for their children, and trailing nils can be left out. An empty
    /// array, or a nil first entry, is the empty tree. O(n).
    public static func make(_ levelOrder: [Int?]) -> TreeNode? {
        guard let first = levelOrder.first, let rootValue = first else { return nil }
        let root = TreeNode(rootValue)
        var parents = [root]
        var head = 0                                  // parents[head] gets the next two entries
        var index = 1
        while index < levelOrder.count && head < parents.count {
            let parent = parents[head]
            head += 1
            if let value = levelOrder[index] {
                parent.left = TreeNode(value)
                parents.append(parent.left!)
            }
            index += 1
            if index < levelOrder.count, let value = levelOrder[index] {
                parent.right = TreeNode(value)
                parents.append(parent.right!)
            }
            index += 1
        }
        return root
    }

    /// The tree in level order, in the same form `make` takes: `nil` for each missing child of a node
    /// that exists, with trailing nils removed. `TreeNode.make(x)?.levelOrder == x` for any `x` without
    /// trailing nils. O(n).
    public var levelOrder: [Int?] {
        var result: [Int?] = []
        var queue: [TreeNode?] = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if let node {
                result.append(node.value)
                queue.append(node.left)
                queue.append(node.right)
            } else {
                result.append(nil)
            }
        }
        while let last = result.last, last == nil {
            result.removeLast()
        }
        return result
    }

    /// The values in inorder (left subtree, node, right subtree). For a binary search tree that's
    /// sorted order. Iterative, so a very deep tree is fine. O(n).
    public var inorder: [Int] {
        var result: [Int] = []
        var stack: [TreeNode] = []
        var current: TreeNode? = self
        while current != nil || !stack.isEmpty {
            while let node = current {
                stack.append(node)
                current = node.left
            }
            let node = stack.removeLast()
            result.append(node.value)
            current = node.right
        }
        return result
    }

    /// The number of nodes in this subtree. O(n).
    public var count: Int {
        var total = 0
        var stack: [TreeNode] = [self]
        while let node = stack.popLast() {
            total += 1
            if let left = node.left { stack.append(left) }
            if let right = node.right { stack.append(right) }
        }
        return total
    }

    /// The number of levels: 1 for a single node, and one more for each level below it. (Some books
    /// count edges instead, which is one less.) O(n).
    public var height: Int {
        var levels = 0
        var level: [TreeNode] = [self]
        while !level.isEmpty {
            levels += 1
            level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
        }
        return levels
    }

    /// The first node holding `value`, searching level by level, or nil if there's none. Handy for
    /// picking out nodes in tests, such as the two nodes of a lowest-common-ancestor query. O(n).
    public func find(_ value: Int) -> TreeNode? {
        var queue: [TreeNode] = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if node.value == value { return node }
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        return nil
    }
}

extension TreeNode: CustomStringConvertible {
    /// The tree in level order, such as `[3, 9, 20, nil, nil, 15, 7]`. O(n).
    public var description: String {
        "[" + levelOrder.map { $0.map(String.init) ?? "nil" }.joined(separator: ", ") + "]"
    }
}
