// Reference solution: Audit a red-black tree. One postorder pass: each call checks its node against the
// open range its ancestors allow (the BST rule) and for a red-red pair, then asks both children for
// their black-heights, which must be equal. The black-height comes back up, or nil for "broken
// somewhere below". The root's colour is checked once. O(n) time, O(h) stack.

public enum RedBlackAudit {
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

    public static func blackHeight(of root: Node?) -> Int? {
        if root?.isRed == true { return nil }                    // rule 2: a black root
        return check(root, above: nil, below: nil)
    }

    /// The black-height of node's subtree if rules 1, 3 and 4 hold there and every value lies strictly
    /// between `above` and `below` (nil for no limit); nil otherwise.
    private static func check(_ node: Node?, above: Int?, below: Int?) -> Int? {
        guard let node else { return 0 }                         // a nil leaf: black, but not counted
        if let above, node.value <= above { return nil }         // rule 1: the BST order
        if let below, node.value >= below { return nil }
        if node.isRed && (node.left?.isRed == true || node.right?.isRed == true) {
            return nil                                           // rule 3: two reds in a row
        }
        guard let left = check(node.left, above: above, below: node.value),
              let right = check(node.right, above: node.value, below: below),
              left == right else { return nil }                  // rule 4: equal black counts
        return left + (node.isRed ? 0 : 1)
    }
}
