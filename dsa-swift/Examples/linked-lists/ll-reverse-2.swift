// Generated from src/dsa/content/lessons/linked-lists/ll-reverse.mdx. Edit the lesson, then run
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

func reverseRecursively(_ head: ListNode?) -> ListNode? {
    guard let head, let second = head.next else {
        return head                       // empty or one node
    }
    let newHead = reverseRecursively(second)   // 2 -> 3 -> 4 becomes 4 -> 3 -> 2
    second.next = head                    // second is the last node now: 4 -> 3 -> 2 -> 1
    head.next = nil                       // and head ends the list
    return newHead
}

print(describe(reverseRecursively(makeList([1, 2, 3, 4]))))
print(describe(reverseRecursively(makeList([1, 2]))))
