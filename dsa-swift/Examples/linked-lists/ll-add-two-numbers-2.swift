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

/// The digits of a decimal string, least significant first.
func digitList(_ text: String) -> ListNode? {
    var head: ListNode? = nil
    for character in text {                     // most significant first...
        head = ListNode(character.wholeNumberValue!, next: head)   // ...so prepending reverses
    }
    return head
}

/// The number as a string, most significant digit first.
func text(of head: ListNode?) -> String {
    var digits: [String] = []
    var current = head
    while let node = current {
        digits.append(String(node.value))
        current = node.next
    }
    return digits.reversed().joined()
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

let big = digitList("987654321098765432109876543210")
let other = digitList("123456789012345678901234567890")
print(text(of: add(big, other)))
