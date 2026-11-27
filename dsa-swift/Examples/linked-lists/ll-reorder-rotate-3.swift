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

func oddEven(_ head: ListNode?) -> ListNode? {
    guard let head else { return nil }
    var odd = head
    let evenHead = head.next
    var even = evenHead

    while let e = even, let nextOdd = e.next {
        odd.next = nextOdd              // odd skips over the even node
        odd = nextOdd
        e.next = nextOdd.next           // even skips over the next odd node
        even = e.next
    }
    odd.next = evenHead                 // odd chain, then even chain
    return head
}

print(describe(oddEven(makeList([1, 2, 3, 4, 5]))))
print(describe(oddEven(makeList([10, 20, 30, 40]))))
print(describe(oddEven(makeList([7]))))
