// Generated from src/dsa/content/lessons/linked-lists/ll-merge-sorted.mdx. Edit the lesson, then run
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

func merge(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
    let dummy = ListNode(0)
    var tail = dummy
    var a = first
    var b = second
    while let left = a, let right = b {
        if left.value <= right.value {
            tail.next = left
            a = left.next
        } else {
            tail.next = right
            b = right.next
        }
        tail = tail.next!
    }
    tail.next = a ?? b          // whatever is left is already sorted
    return dummy.next
}

print(describe(merge(makeList([1, 4, 6]), makeList([2, 3, 7, 8]))))
print(describe(merge(makeList([5, 5, 9]), makeList([1, 5]))))
print(describe(merge(nil, makeList([2, 4]))))
print(describe(merge(nil, nil)))
