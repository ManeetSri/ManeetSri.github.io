// Problem: Deep-copy a list with random links (M25 · Copy a list with random pointers)

public enum RandomLinkListCopy {
    /// A list node with an extra `random` link to any node of the same list, or nil. `random` is weak:
    /// the `next` chain owns the nodes.
    public final class Node {
        public var value: Int
        public var next: Node?
        public weak var random: Node?

        public init(_ value: Int) {
            self.value = value
        }
    }

    /// Returns a deep copy of the list: new nodes with the same values, whose `next` and `random` links
    /// point at the matching nodes of the copy. The original must be left unchanged.
    public static func deepCopy(_ head: Node?) -> Node? {
        // Write your solution here, then run:
        // swift test --filter RandomLinkListCopyTests
        return nil
    }
}
