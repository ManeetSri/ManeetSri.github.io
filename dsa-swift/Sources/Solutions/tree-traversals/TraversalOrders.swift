// Reference solution: Preorder, inorder and postorder. One recursive helper per order, appending to a
// single result array through `inout` so no intermediate arrays are built. The only difference
// between the three is where the append sits relative to the two recursive calls. O(n) time, O(h)
// stack for a tree of height h.

import DSAKit

public enum TraversalOrders {
    public static func preorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        func walk(_ node: TreeNode?) {
            guard let node else { return }
            result.append(node.value)             // before the children
            walk(node.left)
            walk(node.right)
        }
        walk(root)
        return result
    }

    public static func inorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        func walk(_ node: TreeNode?) {
            guard let node else { return }
            walk(node.left)
            result.append(node.value)             // between the children
            walk(node.right)
        }
        walk(root)
        return result
    }

    public static func postorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        func walk(_ node: TreeNode?) {
            guard let node else { return }
            walk(node.left)
            walk(node.right)
            result.append(node.value)             // after the children
        }
        walk(root)
        return result
    }
}
