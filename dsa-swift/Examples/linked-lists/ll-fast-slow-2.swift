// Generated from src/dsa/content/lessons/linked-lists/ll-fast-slow.mdx. Edit the lesson, then run
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

func firstMiddle(_ head: ListNode?) -> ListNode? {
    var slow = head
    var fast = head
    while let next = fast?.next?.next {
        slow = slow?.next
        fast = next
    }
    return slow
}

print(firstMiddle(makeList([1, 2, 3, 4, 5]))?.value ?? -1)
print(firstMiddle(makeList([1, 2, 3, 4, 5, 6]))?.value ?? -1)
print(firstMiddle(makeList([1, 2]))?.value ?? -1)
