// Reference solution: Merge two sorted lists. A dummy head and a tail pointer: repeatedly attach the
// smaller front node, taking from the first list on ties so equal values keep their order, then attach
// whatever is left in one go. O(n + m) time, O(1) extra space, and no new nodes except the dummy.

import DSAKit

public enum MergeSortedLists {
    public static func merged(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
        let dummy = ListNode(0)
        var tail = dummy
        var a = first
        var b = second
        while let left = a, let right = b {
            if left.value <= right.value {
                tail.next = left
                a = left.next
            } else {
                tail.next = right
                b = right.next
            }
            tail = tail.next!
        }
        tail.next = a ?? b             // one list is empty; the other is already sorted
        return dummy.next
    }
}
