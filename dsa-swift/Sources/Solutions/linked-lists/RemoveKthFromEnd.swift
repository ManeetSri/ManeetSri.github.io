// Reference solution: Remove the kth node from the end. A dummy node in front of the head, then two
// pointers k nodes apart: when the leading one reaches the last node, the trailing one is just before the
// node to remove. One pass, O(n) time, O(1) space.

import DSAKit

public enum RemoveKthFromEnd {
    public static func removing(_ head: ListNode?, kthFromEnd k: Int) -> ListNode? {
        let dummy = ListNode(0, next: head)
        var lead: ListNode = dummy
        for _ in 0..<k {
            lead = lead.next!         // k ≤ the length, so these k steps exist
        }
        var trail: ListNode = dummy
        while let next = lead.next {
            lead = next
            trail = trail.next!
        }
        trail.next = trail.next?.next  // trail is just before the kth node from the end
        return dummy.next
    }
}
