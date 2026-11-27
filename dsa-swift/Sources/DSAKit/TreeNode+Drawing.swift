// A picture of a tree, for debugging (M34 · Printing trees). It's an extension in its own file so
// TreeNode.swift stays about the node itself.

/// One piece of work while drawing: lay out a whole subtree, or write one finished line.
private enum DrawingStep {
    case subtree(TreeNode, prefix: String, connector: String, above: String, below: String)
    case line(String)
}

extension TreeNode {
    /// The tree drawn sideways: the root on the left, its right subtree above it and its left subtree
    /// below. Tilt your head to the left to see it the usual way up. `TreeNode.make([1, 2, 3, 4, 5, nil,
    /// 6, nil, nil, 7]).diagram` is:
    ///
    ///         ┌── 6
    ///     ┌── 3
    ///     1
    ///     │   ┌── 5
    ///     │   │   └── 7
    ///     └── 2
    ///         └── 4
    ///
    /// Each node has its own line, and a child's connector sits directly under or over the first
    /// character of its parent's value, so values of any width line up. The lines run from the
    /// rightmost node to the leftmost: reverse inorder. Iterative, so a deep tree can't overflow the
    /// stack, but a tree of height h makes lines up to 4h characters wide: O(n · h) characters for
    /// n nodes.
    public var diagram: String {
        var lines: [String] = []
        var pending: [DrawingStep] = [.subtree(self, prefix: "", connector: "", above: "", below: "")]
        while let step = pending.popLast() {
            switch step {
            case let .line(text):
                lines.append(text)
            case let .subtree(node, prefix, connector, above, below):
                // On the page: right subtree, then this node, then left subtree. The stack hands
                // work back in reverse, so push them the other way round.
                // `above` and `below` continue the line to this node's parent: a right child's parent
                // is below it, so its left subtree (between the two) needs a bar, and vice versa.
                if let left = node.left {
                    pending.append(.subtree(left, prefix: prefix + below, connector: "└── ", above: "│   ", below: "    "))
                }
                pending.append(.line(prefix + connector + String(node.value)))
                if let right = node.right {
                    pending.append(.subtree(right, prefix: prefix + above, connector: "┌── ", above: "    ", below: "│   "))
                }
            }
        }
        return lines.joined(separator: "\n")
    }
}
