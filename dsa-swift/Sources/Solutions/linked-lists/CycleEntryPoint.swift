// Reference solution: Where does the cycle start? Floyd's tortoise and hare. The fast pointer moves two
// steps for every one of the slow pointer, so inside a cycle it gains one node per step and must land on
// the slow pointer. From the meeting point, the cycle's start is as far ahead (going round the loop) as
// it is from the head, so two pointers moving one step at a time meet exactly there.
// O(n) time, O(1) space, and the list is never changed.

import DSAKit

public enum CycleEntryPoint {
    /// The node where slow and fast meet, or nil if fast runs off the end.
    private static func meetingPoint(_ head: ListNode?) -> ListNode? {
        var slow = head
        var fast = head
        while let next = fast?.next {
            slow = slow?.next
            fast = next.next
            if let fast, fast === slow {
                return fast
            }
        }
        return nil
    }

    public static func hasCycle(_ head: ListNode?) -> Bool {
        meetingPoint(head) != nil
    }

    public static func entry(_ head: ListNode?) -> ListNode? {
        guard var inside = meetingPoint(head), var outside = head else {
            return nil
        }
        while outside !== inside {
            outside = outside.next!   // both are on the cycle's path, so neither reaches nil
            inside = inside.next!
        }
        return outside
    }
}
