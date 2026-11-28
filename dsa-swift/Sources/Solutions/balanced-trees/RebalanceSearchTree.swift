// Reference solution: Rebalance a lopsided BST. Collect the nodes in inorder (sorted order) with an
// explicit stack, since the input can be a chain far too deep to recurse down. Then rebuild: the middle
// node becomes the root, and each half becomes a subtree the same way. The halves differ in size by at
// most one, so every node ends up height-balanced, and the rebuild's recursion is only O(log n) deep.
// The nodes are reused, so nothing is allocated besides the array. O(n) time, O(n) space.

import DSAKit

public enum RebalanceSearchTree {
    public static func balanced(_ root: TreeNode?) -> TreeNode? {
        var nodes: [TreeNode] = []
        var stack: [TreeNode] = []
        var current = root
        while current != nil || !stack.isEmpty {
            while let node = current {
                stack.append(node)
                current = node.left
            }
            let node = stack.removeLast()
            nodes.append(node)
            current = node.right
        }
        return build(nodes, 0, nodes.count - 1)
    }

    /// Links nodes[low...high] into a balanced subtree and returns its root.
    private static func build(_ nodes: [TreeNode], _ low: Int, _ high: Int) -> TreeNode? {
        guard low <= high else { return nil }
        let mid = low + (high - low) / 2
        let node = nodes[mid]
        node.left = build(nodes, low, mid - 1)
        node.right = build(nodes, mid + 1, high)
        return node
    }
}
