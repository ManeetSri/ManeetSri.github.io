// Reference solution: Balance, mirror and subtree checks.
// - isBalanced: one bottom-up pass returns each subtree's height, or nil as soon as any subtree is out
//   of balance, so no height is computed twice. O(n).
// - isSymmetric: walk the two halves together, pairing each left child with the matching right child.
//   O(n).
// - mirrored: swap the children of every node. O(n).
// - contains: try "same tree" at every node of the big tree. O(n · m) in the worst case, and far less
//   in practice because a comparison stops at the first difference.

import DSAKit

public enum BalanceMirrorChecks {
    public static func isBalanced(_ root: TreeNode?) -> Bool {
        // The height of node's subtree, or nil if some subtree inside it is unbalanced
        func checkedHeight(_ node: TreeNode?) -> Int? {
            guard let node else { return 0 }
            guard let left = checkedHeight(node.left),
                  let right = checkedHeight(node.right),
                  abs(left - right) <= 1 else { return nil }
            return 1 + max(left, right)
        }
        return checkedHeight(root) != nil
    }

    public static func isSymmetric(_ root: TreeNode?) -> Bool {
        func areMirrors(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
            switch (a, b) {
            case (nil, nil):
                return true
            case let (a?, b?):
                return a.value == b.value && areMirrors(a.left, b.right) && areMirrors(a.right, b.left)
            default:
                return false
            }
        }
        return areMirrors(root?.left, root?.right)
    }

    @discardableResult
    public static func mirrored(_ root: TreeNode?) -> TreeNode? {
        guard let root else { return nil }
        let oldLeft = root.left
        root.left = mirrored(root.right)
        root.right = mirrored(oldLeft)
        return root
    }

    public static func contains(_ pattern: TreeNode?, in tree: TreeNode?) -> Bool {
        guard let pattern else { return true }          // the empty tree is inside every tree
        func isSame(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
            switch (a, b) {
            case (nil, nil):
                return true
            case let (a?, b?):
                return a.value == b.value && isSame(a.left, b.left) && isSame(a.right, b.right)
            default:
                return false
            }
        }
        // Visit every node of the big tree with a stack, and try the pattern there
        var pending: [TreeNode] = tree.map { [$0] } ?? []
        while let node = pending.popLast() {
            if node.value == pattern.value && isSame(node, pattern) {
                return true
            }
            if let left = node.left { pending.append(left) }
            if let right = node.right { pending.append(right) }
        }
        return false
    }
}
