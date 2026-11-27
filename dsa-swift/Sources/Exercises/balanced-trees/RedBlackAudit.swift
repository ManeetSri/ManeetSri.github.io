// Problem: Audit a red-black tree (M38 · Red-black trees)

public enum RedBlackAudit {
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

    /// Returns the black-height of `root` (black nodes on every path down to a nil leaf, not counting
    /// the nil) if it's a valid red-black tree: a BST with strictly increasing inorder values, a black
    /// root, no red node with a red child, and equal black counts on every path. Otherwise nil.
    public static func blackHeight(of root: Node?) -> Int? {
        // Write your solution here, then run:
        // swift test --filter RedBlackAuditTests
        return -1
    }
}
