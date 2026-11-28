// The node every linked-list problem shares (M25). Problems take and return `ListNode?`: `nil` is the
// empty list, and any node is the head of the list that starts there.
//
// It's a class because nodes point at each other: a struct can't contain itself, and two arrows often
// need to reach the same node (M09, Value vs reference semantics).

/// One node of a singly linked list of Ints.
public final class ListNode {
    /// The value stored in this node.
    public var value: Int

    /// The node after this one, or nil at the end of the list.
    public var next: ListNode?

    /// A node holding `value`, pointing at `next`. O(1).
    public init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }

    /// How many nodes `values`, `description` and the other walks visit at most, so a list with a cycle
    /// can't hang a test. Far more than any test uses.
    public static let walkLimit = 1_000_000

    /// Builds a list from `values`, front to back, and returns its head, or nil for an empty array. O(n).
    public static func make(_ values: [Int]) -> ListNode? {
        var head: ListNode? = nil
        for value in values.reversed() {
            head = ListNode(value, next: head)
        }
        return head
    }

    /// Builds a list from `values` whose last node points back at the node at `index`, making a cycle.
    /// With `index` nil it's an ordinary list. Precondition: `index` is a valid index of `values`. O(n).
    ///
    /// A list with a cycle is a retain cycle too (M11), so it's never freed unless you break the loop,
    /// for example with `head.node(at: values.count - 1)?.next = nil`.
    public static func make(_ values: [Int], loopingTo index: Int?) -> ListNode? {
        let head = make(values)
        guard let index, let head else { return head }
        precondition(values.indices.contains(index), "loopingTo must be an index of values")
        let target = head.node(at: index)
        let last = head.node(at: values.count - 1)
        last?.next = target
        return head
    }

    /// The values from this node to the end of the list. A list with a cycle stops after
    /// `ListNode.walkLimit` values, so the result never equals a short expected array. O(n).
    public var values: [Int] {
        var result: [Int] = []
        var current: ListNode? = self
        while let node = current, result.count < ListNode.walkLimit {
            result.append(node.value)
            current = node.next
        }
        return result
    }

    /// The node `index` links further on: `node(at: 0)` is this node. Nil if the list ends first or
    /// `index` is negative. O(index).
    public func node(at index: Int) -> ListNode? {
        guard index >= 0 else { return nil }
        var current: ListNode? = self
        var steps = 0
        while let node = current, steps < index {
            current = node.next
            steps += 1
        }
        return current
    }

    /// The number of nodes from this one to the end. A list with a cycle stops at `ListNode.walkLimit`.
    /// O(n).
    public var count: Int {
        var total = 0
        var current: ListNode? = self
        while let node = current, total < ListNode.walkLimit {
            total += 1
            current = node.next
        }
        return total
    }
}

extension ListNode: CustomStringConvertible {
    /// The list from this node on, such as `1 -> 2 -> 3 -> nil`. Long lists, and lists with a cycle,
    /// stop after 50 values with `-> ...`. O(1) beyond those 50.
    public var description: String {
        var parts: [String] = []
        var current: ListNode? = self
        while let node = current {
            if parts.count == 50 {
                return parts.joined(separator: " -> ") + " -> ..."
            }
            parts.append(String(node.value))
            current = node.next
        }
        return parts.joined(separator: " -> ") + " -> nil"
    }
}
