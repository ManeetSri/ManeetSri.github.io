// Problem: Traversals without recursion (M35 · Iterative traversals with a stack)

import DSAKit

public enum StackTraversals {
    /// The values in preorder (node, left subtree, right subtree), using a loop and an explicit stack
    /// instead of recursion. Trees in the tests can be 100,000 levels deep.
    public static func preorder(_ root: TreeNode?) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter StackTraversalsTests
        return []
    }

    /// The values in inorder (left subtree, node, right subtree), without recursion. Don't use
    /// DSAKit's `inorder`.
    public static func inorder(_ root: TreeNode?) -> [Int] {
        return []
    }

    /// The values in postorder (left subtree, right subtree, node), without recursion.
    public static func postorder(_ root: TreeNode?) -> [Int] {
        return []
    }
}
