// Reference solution: Lowest common ancestor. Each call reports what it found in its subtree: one of
// the two nodes, their common ancestor, or nil. If the two sides each found something, the nodes are
// on different sides and this node is the answer; otherwise the one non-nil result is passed up. Both
// nodes must be in the tree. O(n) time, O(h) stack space.

import DSAKit

public enum DeepestSharedAncestor {
    public static func lowestCommonAncestor(of first: TreeNode, and second: TreeNode, in root: TreeNode?) -> TreeNode? {
        guard let root else { return nil }
        if root === first || root === second {
            return root
        }
        let left = lowestCommonAncestor(of: first, and: second, in: root.left)
        let right = lowestCommonAncestor(of: first, and: second, in: root.right)
        if left != nil && right != nil {
            return root                              // one node on each side
        }
        return left ?? right
    }
}
