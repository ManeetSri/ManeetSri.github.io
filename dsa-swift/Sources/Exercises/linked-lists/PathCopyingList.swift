// Problem: Edit an immutable list by path copying (M25 · Copy-on-write and persistent lists)

public enum PathCopyingList {
    /// A node of an immutable list: it can never change after it's created, so versions can share it.
    public final class Node {
        public let value: Int
        public let next: Node?

        public init(_ value: Int, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    /// Returns a new version with `value` at position `index` (0 ≤ index ≤ length). Copies only the
    /// nodes before `index`; the old node at `index` and everything after it are shared.
    public static func inserting(_ value: Int, at index: Int, into head: Node?) -> Node? {
        // Write your solution here, then run:
        // swift test --filter PathCopyingListTests
        return nil
    }

    /// Returns a new version without the node at `index` (0 ≤ index < length). Copies only the nodes
    /// before `index`; everything after the removed node is shared.
    public static func removing(at index: Int, from head: Node?) -> Node? {
        return nil
    }
}
