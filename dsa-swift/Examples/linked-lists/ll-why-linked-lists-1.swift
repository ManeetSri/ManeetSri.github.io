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

let third = ListNode(30)
let second = ListNode(20, next: third)
let head = ListNode(10, next: second)

var current: ListNode? = head
while let node = current {
    print(node.value, terminator: " -> ")
    current = node.next
}
print("nil")
