// Reference solution: Palindrome linked list. Find the end of the first half with fast and slow pointers,
// reverse the second half, walk both halves together comparing values, then reverse the second half
// back so the caller gets their list unchanged. O(n) time, O(1) extra space.

import DSAKit

public enum PalindromeLinkedList {
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

    public static func isPalindrome(_ head: ListNode?) -> Bool {
        guard let head else { return true }

        // slow stops on the last node of the first half (the middle node, for an odd length)
        var slow = head
        var fast = head
        while let second = fast.next, let third = second.next {
            slow = slow.next!
            fast = third
        }

        let secondHalf = reverse(slow.next)
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

        slow.next = reverse(secondHalf)   // put the list back as it was
        return matches
    }
}
