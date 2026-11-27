// Generated from src/dsa/content/lessons/linked-lists/ll-palindrome-intersection.mdx. Edit the lesson, then run
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

func isPalindrome(_ head: ListNode?) -> Bool {
    guard let head else { return true }

    var firstHalfEnd = head                       // the first middle
    var fast = head
    while let next = fast.next?.next {
        firstHalfEnd = firstHalfEnd.next!
        fast = next
    }

    let secondHalf = reverse(firstHalfEnd.next)
    var left: ListNode? = head
    var right = secondHalf
    var matches = true
    while let r = right, let l = left {
        if l.value != r.value {
            matches = false
            break
        }
        left = l.next
        right = r.next
    }

    firstHalfEnd.next = reverse(secondHalf)       // restore the list
    return matches
}

for values in [[1, 2, 3, 2, 1], [4, 4], [1, 2, 2, 1], [1, 2, 3], [7]] {
    let list = makeList(values)
    print(values, isPalindrome(list), describe(list))
}
