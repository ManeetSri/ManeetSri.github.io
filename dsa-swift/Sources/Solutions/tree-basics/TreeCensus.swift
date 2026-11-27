// Reference solution: Tree census. Each answer is "the answer for this node, combined with the answers
// for its two subtrees", so each function is a short recursion that visits every node once: O(n)
// time, and O(h) stack for a tree of height h.

import DSAKit

public enum TreeCensus {
    public static func size(_ root: TreeNode?) -> Int {
        guard let root else { return 0 }
        return 1 + size(root.left) + size(root.right)
    }

    public static func leaves(_ root: TreeNode?) -> Int {
        guard let root else { return 0 }
        if root.left == nil && root.right == nil {
            return 1
        }
        return leaves(root.left) + leaves(root.right)
    }

    public static func depth(of value: Int, in root: TreeNode?) -> Int? {
        guard let root else { return nil }
        if root.value == value {
            return 0
        }
        // Found in a subtree at depth d below the child means d + 1 below this node
        if let below = depth(of: value, in: root.left) ?? depth(of: value, in: root.right) {
            return below + 1
        }
        return nil
    }
}
