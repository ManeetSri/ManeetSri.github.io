// Reference solution: Level by level. Breadth-first search one whole level at a time: `level` holds
// every node on the current level, left to right, and their children, in order, make the next level.
// Each node is handled once: O(n) time, and O(w) space for the widest level w. The bottom-up version
// reverses the finished groups, and the N-ary version loops over `children` instead of left and right.

import DSAKit

public enum LevelOrderGroups {
    public final class Node {
        public let value: Int
        public var children: [Node]

        public init(_ value: Int, children: [Node] = []) {
            self.value = value
            self.children = children
        }
    }

    public static func levels(_ root: TreeNode?) -> [[Int]] {
        var result: [[Int]] = []
        var level = [root].compactMap { $0 }
        while !level.isEmpty {
            result.append(level.map(\.value))
            var next: [TreeNode] = []
            for node in level {
                if let left = node.left { next.append(left) }
                if let right = node.right { next.append(right) }
            }
            level = next
        }
        return result
    }

    public static func levelsBottomUp(_ root: TreeNode?) -> [[Int]] {
        Array(levels(root).reversed())
    }

    public static func naryLevels(_ root: Node?) -> [[Int]] {
        var result: [[Int]] = []
        var level = [root].compactMap { $0 }
        while !level.isEmpty {
            result.append(level.map(\.value))
            level = level.flatMap(\.children)
        }
        return result
    }
}
