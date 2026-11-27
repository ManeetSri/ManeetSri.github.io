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

func kthFromEnd(_ head: ListNode?, k: Int) -> Int? {
    var lead = head
    for _ in 0..<k {
        guard let node = lead else { return nil }
        lead = node.next
    }
    var trail = head
    while let node = lead {
        lead = node.next
        trail = trail?.next
    }
    return trail?.value
}

let list = makeList([10, 20, 30, 40, 50])
print(kthFromEnd(list, k: 1) ?? -1)
print(kthFromEnd(list, k: 3) ?? -1)
print(kthFromEnd(list, k: 5) ?? -1)
print(kthFromEnd(list, k: 6) ?? -1)
