// Reference solution: Add two digit lists, most significant first. Copy each list's digits into an
// array, then pop from the ends to add from the units upwards with a carry, prepending each new digit so
// the answer comes out most significant first. The inputs are only read. O(m + n) time and space.

import DSAKit

public enum ForwardDigitListSum {
    public static func add(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
        var left = first?.values ?? []
        var right = second?.values ?? []
        var head: ListNode? = nil
        var carry = 0
        while !left.isEmpty || !right.isEmpty || carry > 0 {
            let column = (left.popLast() ?? 0) + (right.popLast() ?? 0) + carry
            head = ListNode(column % 10, next: head)     // prepend: the units end up last
            carry = column / 10
        }
        return head
    }
}
