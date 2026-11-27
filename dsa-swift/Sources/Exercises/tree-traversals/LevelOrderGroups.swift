// Problem: Level by level (M35 · Level-order traversal with a queue)

import DSAKit

public enum LevelOrderGroups {
    /// A node of an N-ary tree: any number of children, in order.
    public final class Node {
        public let value: Int
        public var children: [Node]

        public init(_ value: Int, children: [Node] = []) {
            self.value = value
            self.children = children
        }
    }

    /// The values level by level: one array per level, from the root down, each left to right. The
    /// empty tree gives `[]`.
    public static func levels(_ root: TreeNode?) -> [[Int]] {
        // Write your solution here, then run:
        // swift test --filter LevelOrderGroupsTests
        return []
    }

    /// The same groups, but from the deepest level up to the root. Each level still reads left to right.
    public static func levelsBottomUp(_ root: TreeNode?) -> [[Int]] {
        return []
    }

    /// Level by level for an N-ary tree: each level lists its nodes left to right, children in order.
    public static func naryLevels(_ root: Node?) -> [[Int]] {
        return []
    }
}
