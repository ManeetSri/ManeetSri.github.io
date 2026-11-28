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

func reverse(_ head: ListNode?) -> ListNode? {
    var previous: ListNode? = nil
    var current = head
    while let node = current {
        let next = node.next      // save the rest of the list
        node.next = previous      // turn this arrow around
        previous = node           // the reversed part now starts here
        current = next            // carry on with the rest
    }
    return previous               // the old last node
}

print(describe(reverse(makeList([1, 2, 3, 4, 5]))))
print(describe(reverse(makeList([7]))))
print(describe(reverse(makeList([]))))
