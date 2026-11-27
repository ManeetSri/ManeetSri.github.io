// Generated from src/dsa/content/lessons/linked-lists/ll-remove-nth.mdx. Edit the lesson, then run
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

func removeOnePass(_ head: ListNode?, nthFromEnd n: Int) -> ListNode? {
    let dummy = ListNode(0, next: head)
    var lead = dummy
    for _ in 0..<n {
        guard let next = lead.next else {
            return head                 // fewer than n nodes: nothing to remove
        }
        lead = next
    }
    var trail = dummy
    while let next = lead.next {
        lead = next
        trail = trail.next!
    }
    trail.next = trail.next?.next       // skip the nth node from the end
    return dummy.next
}

print(describe(removeOnePass(makeList([1, 2, 3, 4, 5]), nthFromEnd: 2)))
print(describe(removeOnePass(makeList([1, 2, 3, 4, 5]), nthFromEnd: 1)))
print(describe(removeOnePass(makeList([1, 2, 3, 4, 5]), nthFromEnd: 5)))
print(describe(removeOnePass(makeList([9]), nthFromEnd: 1)))
print(describe(removeOnePass(makeList([1, 2]), nthFromEnd: 3)))
