// Generated from src/dsa/content/lessons/linked-lists/ll-add-two-numbers.mdx. Edit the lesson, then run
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
        let next = node.next
        node.next = previous
        previous = node
        current = next
    }
    return previous
}

func add(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
    let dummy = ListNode(0)
    var tail = dummy
    var a = first
    var b = second
    var carry = 0
    while a != nil || b != nil || carry > 0 {
        let sum = (a?.value ?? 0) + (b?.value ?? 0) + carry
        tail.next = ListNode(sum % 10)
        tail = tail.next!
        carry = sum / 10
        a = a?.next
        b = b?.next
    }
    return dummy.next
}

func addForwards(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
    let a = reverse(first)
    let b = reverse(second)
    let sum = reverse(add(a, b))
    _ = reverse(a)                  // put the inputs back the way they were
    _ = reverse(b)
    return sum
}

let x = makeList([7, 2, 4, 3])      // 7243
let y = makeList([5, 6, 4])         // 564
print(describe(addForwards(x, y)))
print(describe(x), describe(y))
