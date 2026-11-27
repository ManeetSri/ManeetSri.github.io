// Generated from src/dsa/content/lessons/linked-lists/ll-sequence.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ListNode {
    var value: Int
    var next: ListNode?

    init(_ value: Int, next: ListNode? = nil) {
        self.value = value
        self.next = next
    }
}

let head = ListNode(4, next: ListNode(8, next: ListNode(15, next: ListNode(16))))

let nodes = sequence(first: head) { $0.next }
print(nodes.map { $0.value })
print(nodes.count(where: { $0.value.isMultiple(of: 2) }))

var last = head
for node in nodes {
    last = node
}
print("last node holds", last.value)
