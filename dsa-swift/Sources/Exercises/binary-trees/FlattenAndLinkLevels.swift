// Problem: Flatten a tree and link its levels (M36 · Flatten a tree and populate next pointers)

import DSAKit

public enum FlattenAndLinkLevels {
    /// A binary tree node with one more link: `next`, the node to its right on the same level.
    public final class LevelNode {
        public var value: Int
        public var left: LevelNode?
        public var right: LevelNode?
        public var next: LevelNode?

        public init(_ value: Int, left: LevelNode? = nil, right: LevelNode? = nil) {
            self.value = value
            self.left = left
            self.right = right
        }
    }

    /// Rewires the tree in place into a chain that follows `right` links in preorder: every `left`
    /// becomes nil, and each node's `right` is the node that comes after it in preorder. Reuse the
    /// nodes: don't create any.
    public static func flatten(_ root: TreeNode?) {
        // Write your solution here, then run:
        // swift test --filter FlattenAndLinkLevelsTests
    }

    /// Sets every node's `next` to the node directly to its right on the same level, or nil for the
    /// last node of each level. Leave `left` and `right` as they are. The tree can have any shape.
    public static func linkLevels(_ root: LevelNode?) {
    }
}
