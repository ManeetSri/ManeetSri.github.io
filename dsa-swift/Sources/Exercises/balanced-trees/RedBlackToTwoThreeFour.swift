// Problem: Read a red-black tree as a 2-3-4 tree (M38 · 2-3-4 trees)

public enum RedBlackToTwoThreeFour {
    /// One node of a red-black tree. Written for you.
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

    /// The 2-3-4 tree that the valid red-black tree `root` encodes, level by level from the top: each
    /// level lists its nodes left to right, and each node is its keys in increasing order. A black node
    /// and its red children form one 2-3-4 node. The empty tree has no levels.
    public static func levels(of root: Node?) -> [[[Int]]] {
        // Write your solution here, then run:
        // swift test --filter RedBlackToTwoThreeFourTests
        return []
    }
}
