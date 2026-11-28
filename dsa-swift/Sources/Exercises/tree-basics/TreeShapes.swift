// Problem: Name that tree shape (M34 · Full, complete, perfect, balanced and degenerate trees)

import DSAKit

public enum TreeShapes {
    /// True if every node has either no children or two children. The empty tree counts as full.
    public static func isFull(_ root: TreeNode?) -> Bool {
        // Write your solution here, then run:
        // swift test --filter TreeShapesTests
        return false
    }

    /// True if every node other than a leaf has two children and all the leaves are on the same
    /// level. The empty tree counts as perfect.
    public static func isPerfect(_ root: TreeNode?) -> Bool {
        return false
    }

    /// True if every level is completely filled except possibly the last, and the last level's nodes
    /// are packed to the left. The empty tree counts as complete.
    public static func isComplete(_ root: TreeNode?) -> Bool {
        return false
    }

    /// True if no node has two children, so the tree is a single chain. The empty tree counts too.
    public static func isDegenerate(_ root: TreeNode?) -> Bool {
        return false
    }
}
