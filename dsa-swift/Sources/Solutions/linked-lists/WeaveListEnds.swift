// Reference solution: Weave the front and back of a list. Find the first middle with fast and slow
// pointers and cut there, reverse the back half, then weave the halves together one node from each in
// turn. O(n) time, O(1) extra space.

import DSAKit

public enum WeaveListEnds {
    public static func reorder(_ head: ListNode?) {
        guard let head else { return }
        // 1. Find the first middle and cut the list after it
        var slow = head
        var fast = head
        while let next = fast.next?.next {
            slow = slow.next!
            fast = next
        }
        var back = reverse(slow.next)
        slow.next = nil

        // 2. Weave: front node, back node, front node, ...
        var front: ListNode? = head
        while let f = front, let b = back {
            let frontNext = f.next
            let backNext = b.next
            f.next = b
            b.next = frontNext
            front = frontNext
            back = backNext
        }
    }

    private static func reverse(_ head: ListNode?) -> ListNode? {
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
}
