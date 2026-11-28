// Generated from src/dsa/content/lessons/linked-lists/ll-reverse-k-group.mdx. Edit the lesson, then run
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

func reverseInGroups(_ head: ListNode?, k: Int) -> ListNode? {
    guard k > 1 else { return head }
    let dummy = ListNode(0, next: head)
    var groupBefore = dummy

    while true {
        // 1. Look ahead: is there a whole group?
        var probe: ListNode? = groupBefore
        for _ in 0..<k {
            probe = probe?.next
        }
        guard let groupLast = probe else { break }

        let groupFirst = groupBefore.next!
        let after = groupLast.next

        // 2. Reverse exactly k nodes, starting the reversed chain at `after`
        var previous = after
        var current: ListNode? = groupFirst
        for _ in 0..<k {
            let node = current!
            let next = node.next
            node.next = previous
            previous = node
            current = next
        }

        // 3. Reconnect the front, 4. move on
        groupBefore.next = groupLast
        groupBefore = groupFirst
    }
    return dummy.next
}

print(describe(reverseInGroups(makeList([1, 2, 3, 4, 5, 6, 7, 8]), k: 3)))
print(describe(reverseInGroups(makeList([1, 2, 3, 4, 5]), k: 2)))
print(describe(reverseInGroups(makeList([1, 2, 3, 4]), k: 4)))
print(describe(reverseInGroups(makeList([1, 2, 3]), k: 4)))
print(describe(reverseInGroups(makeList([1, 2, 3]), k: 1)))
