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
    tail.next = a ?? b
    return dummy.next
}

func mergeSort(_ head: ListNode?) -> ListNode? {
    guard let head, head.next != nil else {
        return head                          // zero or one node: sorted
    }
    // Find the end of the first half (the first middle), then cut after it
    var slow = head
    var fast = head
    while let next = fast.next?.next {
        slow = slow.next!
        fast = next
    }
    let secondHalf = slow.next
    slow.next = nil
    return merge(mergeSort(head), mergeSort(secondHalf))
}

print(describe(mergeSort(makeList([5, 2, 9, 1, 5, 6, 3]))))
print(describe(mergeSort(makeList([2, 1]))))
print(describe(mergeSort(makeList([]))))
