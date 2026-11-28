// Reference solution: Partition a list around a pivot. Unzip the list into two chains, each behind a
// dummy node, appending every node to the chain for its group; then join the small chain to the rest and
// end the list. O(n) time, O(1) extra space.

import DSAKit

public enum PivotListPartition {
    public static func partitioned(_ head: ListNode?, around pivot: Int) -> ListNode? {
        let smallDummy = ListNode(0)
        let restDummy = ListNode(0)
        var smallTail = smallDummy
        var restTail = restDummy
        var current = head
        while let node = current {
            current = node.next
            if node.value < pivot {
                smallTail.next = node
                smallTail = node
            } else {
                restTail.next = node
                restTail = node
            }
        }
        restTail.next = nil                  // the last node may still point into the small chain
        smallTail.next = restDummy.next      // small chain, then the rest
        return smallDummy.next
    }
}
