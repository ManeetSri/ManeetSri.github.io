// Reference solution: Flatten a tree and link its levels.
// - flatten: at each node with a left subtree, the left subtree's preorder ends at its rightmost node.
//   Hang the right subtree off that node, move the left subtree to the right, and carry on down the
//   right. Each node is walked over at most once while finding those rightmost nodes: O(n) time, O(1)
//   extra space.
// - linkLevels: walk each level along the next pointers already set, and link the level below behind a
//   dummy node. O(n) time, O(1) extra space.

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

    public static func flatten(_ root: TreeNode?) {
        var current = root
        while let node = current {
            if let left = node.left {
                var last = left                      // the end of the left subtree's preorder
                while let next = last.right {
                    last = next
                }
                last.right = node.right
                node.right = left
                node.left = nil
            }
            current = node.right
        }
    }

    public static func linkLevels(_ root: LevelNode?) {
        var levelStart = root
        while let start = levelStart {
            let dummy = LevelNode(0)                 // the level below is linked up behind this
            var tail = dummy
            var current: LevelNode? = start
            while let node = current {
                if let left = node.left {
                    tail.next = left
                    tail = left
                }
                if let right = node.right {
                    tail.next = right
                    tail = right
                }
                current = node.next
            }
            levelStart = dummy.next
        }
    }
}
