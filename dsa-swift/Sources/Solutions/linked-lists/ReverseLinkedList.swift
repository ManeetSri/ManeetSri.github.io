// Reference solution: Reverse a linked list. The loop turns each arrow around with three pointers:
// O(n) time, O(1) space. The recursive version reverses the rest of the list first, then hooks the
// current node onto the end: O(n) time and O(n) stack, one frame per node.

import DSAKit

public enum ReverseLinkedList {
    public static func reversed(_ head: ListNode?) -> ListNode? {
        var previous: ListNode? = nil
        var current = head
        while let node = current {
            let next = node.next      // remember the rest before the arrow turns
            node.next = previous
            previous = node
            current = next
        }
        return previous
    }

    public static func reversedRecursively(_ head: ListNode?) -> ListNode? {
        guard let head, let second = head.next else {
            return head               // empty or one node: already reversed
        }
        let newHead = reversedRecursively(second)
        second.next = head            // second is now the last node of the reversed rest
        head.next = nil
        return newHead
    }
}
