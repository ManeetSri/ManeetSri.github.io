// Generated from src/dsa/content/lessons/linked-lists/ll-sentinel.mdx. Edit the lesson, then run
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

func partition(_ head: ListNode?, around pivot: Int) -> ListNode? {
    let smallDummy = ListNode(0)
    let largeDummy = ListNode(0)
    var smallTail = smallDummy
    var largeTail = largeDummy

    var current = head
    while let node = current {
        current = node.next
        if node.value < pivot {
            smallTail.next = node
            smallTail = node
        } else {
            largeTail.next = node
            largeTail = node
        }
    }
    largeTail.next = nil               // the last node might still point somewhere
    smallTail.next = largeDummy.next   // join the two lists
    return smallDummy.next
}

print(describe(partition(makeList([5, 1, 8, 3, 9, 2]), around: 5)))
print(describe(partition(makeList([9, 8, 7]), around: 5)))
print(describe(partition(makeList([1, 2]), around: 5)))
