// Generated from src/dsa/content/lessons/linked-lists/ll-reorder-rotate.mdx. Edit the lesson, then run
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

func reverse(_ head: ListNode?) -> ListNode? {
    var previous: ListNode? = nil
    var current = head
    while let node = current {
        let next = node.next
        node.next = previous
        previous = node
        current = next
    }
    return previous
}

func reorder(_ head: ListNode?) {
    guard let head else { return }

    // 1. Split after the first middle
    var slow = head
    var fast = head
    while let next = fast.next?.next {
        slow = slow.next!
        fast = next
    }
    var back = reverse(slow.next)     // 2. reverse the back half
    slow.next = nil

    // 3. Weave: front node, back node, front node, ...
    var front: ListNode? = head
    while let f = front, let b = back {
        let frontNext = f.next
        let backNext = b.next
        f.next = b
        b.next = frontNext
        front = frontNext
        back = backNext
    }
}

for values in [[1, 2, 3, 4, 5], [1, 2, 3, 4], [1, 2], [1]] {
    let list = makeList(values)
    reorder(list)
    print(describe(list))
}
