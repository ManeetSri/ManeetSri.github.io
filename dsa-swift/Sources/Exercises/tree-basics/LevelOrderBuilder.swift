// Problem: Level order in and out (M34 · Building a tree from a level-order array)

import DSAKit

public enum LevelOrderBuilder {
    /// Builds the tree described by `levelOrder` and returns its root. The array lists the nodes level
    /// by level, left to right, with nil for each missing child of a node that exists; trailing nils
    /// may be left out. An empty array, or a nil first entry, is the empty tree. Write it yourself:
    /// don't call `TreeNode.make`.
    public static func build(_ levelOrder: [Int?]) -> TreeNode? {
        // Write your solution here, then run:
        // swift test --filter LevelOrderBuilderTests
        return nil
    }

    /// The reverse: the tree written in the same format, with trailing nils removed. The empty tree is
    /// `[]`. Don't use DSAKit's `levelOrder`.
    public static func levelOrder(_ root: TreeNode?) -> [Int?] {
        return []
    }
}
