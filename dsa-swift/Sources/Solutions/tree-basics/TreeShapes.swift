// Reference solution: Name that tree shape. Each test is a walk that visits every node at most once,
// O(n) time, and none of them recurses, so deep trees are safe.
// - Full: check each node's pair of children with a stack.
// - Perfect: level by level, each level must hold exactly twice as many nodes as the one above it,
//   until a level of leaves, which must be the last.
// - Complete: in level order, counting nil children too, no node may come after the first nil.
// - Degenerate: follow the only child down; a node with two children ends it.

import DSAKit

public enum TreeShapes {
    public static func isFull(_ root: TreeNode?) -> Bool {
        var stack = [root].compactMap { $0 }
        while let node = stack.popLast() {
            switch (node.left, node.right) {
            case (nil, nil):
                continue
            case let (left?, right?):
                stack.append(left)
                stack.append(right)
            default:
                return false                      // exactly one child
            }
        }
        return true
    }

    public static func isPerfect(_ root: TreeNode?) -> Bool {
        guard let root else { return true }
        var level = [root]
        while true {
            var next: [TreeNode] = []
            for node in level {
                if let left = node.left { next.append(left) }
                if let right = node.right { next.append(right) }
            }
            if next.isEmpty {
                return true                       // every node on this level is a leaf
            }
            if next.count != 2 * level.count {
                return false                      // someone above has fewer than two children
            }
            level = next
        }
    }

    public static func isComplete(_ root: TreeNode?) -> Bool {
        var queue: [TreeNode?] = [root]
        var head = 0
        var seenGap = false
        while head < queue.count {
            let node = queue[head]
            head += 1
            if let node {
                if seenGap {
                    return false                  // a real node after a gap
                }
                queue.append(node.left)
                queue.append(node.right)
            } else {
                seenGap = true
            }
        }
        return true
    }

    public static func isDegenerate(_ root: TreeNode?) -> Bool {
        var current = root
        while let node = current {
            if node.left != nil && node.right != nil {
                return false
            }
            current = node.left ?? node.right
        }
        return true
    }
}
