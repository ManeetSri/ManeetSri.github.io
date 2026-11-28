// Generated from src/dsa/content/lessons/linked-lists/ll-reverse.mdx. Edit the lesson, then run
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

/// Reverses positions from...to (counting from 0). Assumes 0 ≤ from ≤ to < the list's length.
func reverse(_ head: ListNode?, from: Int, to: Int) -> ListNode? {
    let dummy = ListNode(0, next: head)
    var before = dummy
    for _ in 0..<from {
        before = before.next!
    }

    let partFirst = before.next!          // will end up last in the part
    var previous: ListNode? = nil
    var current: ListNode? = partFirst
    for _ in from...to {
        let node = current!
        let next = node.next
        node.next = previous
        previous = node
        current = next
    }

    before.next = previous                // the node before the part -> new first
    partFirst.next = current              // new last -> whatever followed the part
    return dummy.next
}

print(describe(reverse(makeList([1, 2, 3, 4, 5, 6, 7]), from: 2, to: 4)))
print(describe(reverse(makeList([1, 2, 3, 4]), from: 0, to: 1)))
print(describe(reverse(makeList([1, 2, 3]), from: 0, to: 2)))
print(describe(reverse(makeList([1, 2, 3]), from: 1, to: 1)))
