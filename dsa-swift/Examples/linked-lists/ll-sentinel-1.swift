// Generated from src/dsa/content/lessons/linked-lists/ll-sentinel.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}

func makeList(_ values: [Int]) -> ListNode? {
    var head: ListNode? = nil
    for value in values.reversed() {
        head = ListNode(value, next: head)
    }
    return head
}

func describe(_ head: ListNode?) -> String {
    var parts: [String] = []
    var current = head
    while let node = current {
        parts.append(String(node.value))
        current = node.next
    }
    parts.append("nil")
    return parts.joined(separator: " -> ")
}

func removeAll(_ target: Int, from head: ListNode?) -> ListNode? {
    var head = head
    // Special case: matching nodes at the front move the head
    while let first = head, first.value == target {
        head = first.next
    }
    // General case: every remaining node has a node before it
    var previous = head
    while let node = previous?.next {
        if node.value == target {
            previous?.next = node.next
        } else {
            previous = node
        }
    }
    return head
}

print(describe(removeAll(7, from: makeList([7, 7, 1, 7, 2, 7]))))
print(describe(removeAll(7, from: makeList([7, 7]))))
