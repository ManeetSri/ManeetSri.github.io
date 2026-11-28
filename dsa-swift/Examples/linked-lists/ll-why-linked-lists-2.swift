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

let second = ListNode(20)
let head = ListNode(10, next: second)
let lookalike = ListNode(20)

print(head.next === second)
print(head.next === lookalike)
second.value = 25
print(head.next!.value)
