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

func removeTwoPass(_ head: ListNode?, nthFromEnd n: Int) -> ListNode? {
    var length = 0
    var current = head
    while let node = current {
        length += 1
        current = node.next
    }

    let dummy = ListNode(0, next: head)
    var before = dummy
    for _ in 0..<(length - n) {        // the dummy is one step before position 0
        before = before.next!
    }
    before.next = before.next?.next
    return dummy.next
}

print(describe(removeTwoPass(makeList([1, 2, 3, 4, 5]), nthFromEnd: 2)))
print(describe(removeTwoPass(makeList([1, 2, 3, 4, 5]), nthFromEnd: 5)))
print(describe(removeTwoPass(makeList([9]), nthFromEnd: 1)))
