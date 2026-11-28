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

func reverseInGroupsRecursively(_ head: ListNode?, k: Int) -> ListNode? {
    // Is there a whole group? Find the node after it.
    var after = head
    for _ in 0..<k {
        guard let node = after else { return head }   // too short: leave it
        after = node.next
    }
    // Reverse the group onto the already-processed rest of the list
    var previous = reverseInGroupsRecursively(after, k: k)
    var current = head
    for _ in 0..<k {
        let node = current!
        let next = node.next
        node.next = previous
        previous = node
        current = next
    }
    return previous
}

print(describe(reverseInGroupsRecursively(makeList([1, 2, 3, 4, 5, 6, 7, 8]), k: 3)))
