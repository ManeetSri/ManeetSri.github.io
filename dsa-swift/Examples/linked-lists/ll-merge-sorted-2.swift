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

func mergeRecursively(_ a: ListNode?, _ b: ListNode?) -> ListNode? {
    guard let a else { return b }
    guard let b else { return a }
    if a.value <= b.value {
        a.next = mergeRecursively(a.next, b)
        return a
    } else {
        b.next = mergeRecursively(a, b.next)
        return b
    }
}

print(describe(mergeRecursively(makeList([1, 4, 6]), makeList([2, 3, 7, 8]))))
