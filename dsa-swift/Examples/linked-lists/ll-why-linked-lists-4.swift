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

func node(at index: Int, from head: ListNode?) -> ListNode? {
    var current = head
    var steps = 0
    while let node = current, steps < index {
        current = node.next
        steps += 1
    }
    return current
}

let head = ListNode(10, next: ListNode(20, next: ListNode(30)))
print(node(at: 0, from: head)?.value ?? -1)
print(node(at: 2, from: head)?.value ?? -1)
print(node(at: 5, from: head)?.value ?? -1)
