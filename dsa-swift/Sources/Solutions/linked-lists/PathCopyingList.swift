// Reference solution: Edit an immutable list by path copying. Walk `index` steps, saving the values on
// the way; the node reached is where sharing starts. Rebuild just that front section, from the back, onto
// the new node (insert) or onto the node after the removed one (remove). O(index) time and extra space.

public enum PathCopyingList {
    public final class Node {
        public let value: Int
        public let next: Node?

        public init(_ value: Int, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    public static func inserting(_ value: Int, at index: Int, into head: Node?) -> Node? {
        let (path, rest) = split(head, at: index)
        return rebuild(path, onto: Node(value, next: rest))
    }

    public static func removing(at index: Int, from head: Node?) -> Node? {
        let (path, rest) = split(head, at: index)
        return rebuild(path, onto: rest?.next)         // skip the removed node
    }

    /// The values of the first `index` nodes, and the node at `index`, where sharing starts.
    private static func split(_ head: Node?, at index: Int) -> ([Int], Node?) {
        var path: [Int] = []
        var current = head
        while path.count < index, let node = current {
            path.append(node.value)
            current = node.next
        }
        return (path, current)
    }

    /// New nodes holding `path`, in order, in front of `tail`.
    private static func rebuild(_ path: [Int], onto tail: Node?) -> Node? {
        var result = tail
        for value in path.reversed() {
            result = Node(value, next: result)
        }
        return result
    }
}
