// Generated from src/dsa/content/lessons/linked-lists/ll-why-linked-lists.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
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

let head = ListNode(10, next: ListNode(20, next: ListNode(30)))
print(describe(head))

let fifteen = ListNode(15, next: head.next)   // 15 points at 20
head.next = fifteen                           // 10 points at 15
print(describe(head))

head.next = head.next?.next                   // skip over 15 to remove it
print(describe(head))
