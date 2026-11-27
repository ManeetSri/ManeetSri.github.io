// Reference solution: Read a red-black tree as a 2-3-4 tree. Each black node, with any red children,
// is one 2-3-4 node: its keys are the red left child's value, its own and the red right child's value,
// in that (sorted) order, and its children are the red children's children or the black children
// themselves. A level-order walk over black nodes lists the 2-3-4 tree level by level. O(n) time.

public enum RedBlackToTwoThreeFour {
    public final class Node {
        public var value: Int
        public var isRed: Bool
        public var left: Node?
        public var right: Node?

        public init(_ value: Int, red: Bool = false, left: Node? = nil, right: Node? = nil) {
            self.value = value
            self.isRed = red
            self.left = left
            self.right = right
        }
    }

    public static func levels(of root: Node?) -> [[[Int]]] {
        var result: [[[Int]]] = []
        var level = [root].compactMap { $0 }                     // black nodes: one per 2-3-4 node
        while !level.isEmpty {
            var keys: [[Int]] = []
            var next: [Node] = []
            for black in level {
                var cluster: [Int] = []
                var children: [Node?] = []
                if let left = black.left, left.isRed {
                    cluster.append(left.value)                   // a red left child joins the cluster
                    children += [left.left, left.right]
                } else {
                    children.append(black.left)
                }
                cluster.append(black.value)
                if let right = black.right, right.isRed {
                    cluster.append(right.value)                  // so does a red right child
                    children += [right.left, right.right]
                } else {
                    children.append(black.right)
                }
                keys.append(cluster)
                next += children.compactMap { $0 }               // black, or nil at the bottom
            }
            result.append(keys)
            level = next
        }
        return result
    }
}
