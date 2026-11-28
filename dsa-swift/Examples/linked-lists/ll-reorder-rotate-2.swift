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

func rotateRight(_ head: ListNode?, by k: Int) -> ListNode? {
    guard let head else { return nil }

    var tail = head
    var length = 1
    while let next = tail.next {
        tail = next
        length += 1
    }

    let shift = k % length
    if shift == 0 {
        return head
    }

    tail.next = head                     // close the ring
    var newTail = head
    for _ in 0..<(length - shift - 1) {
        newTail = newTail.next!
    }
    let newHead = newTail.next
    newTail.next = nil                   // cut it open again
    return newHead
}

print(describe(rotateRight(makeList([1, 2, 3, 4, 5]), by: 2)))
print(describe(rotateRight(makeList([1, 2, 3, 4, 5]), by: 7)))
print(describe(rotateRight(makeList([1, 2, 3]), by: 3)))
print(describe(rotateRight(makeList([1, 2]), by: 1)))
