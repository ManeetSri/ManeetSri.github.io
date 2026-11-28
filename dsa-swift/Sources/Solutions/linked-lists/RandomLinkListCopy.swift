// Reference solution: Deep-copy a list with random links. First pass: a copy of every node, filed in a
// dictionary under its original's ObjectIdentifier. Second pass: each copy's `next` and `random` are the
// copies of its original's `next` and `random`. O(n) time, O(n) extra space; the original is only read.

public enum RandomLinkListCopy {
    public final class Node {
        public var value: Int
        public var next: Node?
        public weak var random: Node?

        public init(_ value: Int) {
            self.value = value
        }
    }

    public static func deepCopy(_ head: Node?) -> Node? {
        var copies: [ObjectIdentifier: Node] = [:]
        var current = head
        while let node = current {
            copies[ObjectIdentifier(node)] = Node(node.value)
            current = node.next
        }
        current = head
        while let node = current {
            let copy = copies[ObjectIdentifier(node)]!
            copy.next = node.next.flatMap { copies[ObjectIdentifier($0)] }
            copy.random = node.random.flatMap { copies[ObjectIdentifier($0)] }
            current = node.next
        }
        return head.flatMap { copies[ObjectIdentifier($0)] }
    }
}
