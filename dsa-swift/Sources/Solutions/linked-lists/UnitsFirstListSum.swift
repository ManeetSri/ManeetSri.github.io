// Reference solution: Add two digit lists, units first. Walk both lists together, adding a column per
// step with a carry, and append each digit to a new list behind a dummy head. A finished list counts as
// 0, and the loop runs on while there's a carry. O(max(m, n)) time; the inputs are only read.

import DSAKit

public enum UnitsFirstListSum {
    public static func add(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
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
}
