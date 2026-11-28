// Reference solution: Reverse in groups of k. A dummy node, and `groupBefore`, the node just before the
// next group. Check that k nodes remain; if they do, reverse exactly those k with the usual three
// pointers, then reconnect: the group's old first node is now its last, so it links to what follows and
// becomes the next `groupBefore`. A short final group is left alone. O(n) time, O(1) extra space.

import DSAKit

public enum ReverseInGroups {
    public static func reversed(_ head: ListNode?, groupSize k: Int) -> ListNode? {
        guard k > 1 else { return head }
        let dummy = ListNode(0, next: head)
        var groupBefore = dummy

        while true {
            // Is there a whole group left? Find its last node.
            var groupLast: ListNode? = groupBefore
            for _ in 0..<k {
                groupLast = groupLast?.next
            }
            guard let last = groupLast else { break }

            let groupFirst = groupBefore.next!
            let after = last.next

            // Reverse the k nodes, starting the reversed chain off pointing at `after`.
            var previous = after
            var current: ListNode? = groupFirst
            while let node = current, node !== after {
                let next = node.next
                node.next = previous
                previous = node
                current = next
            }

            groupBefore.next = last       // the old last node starts the group now
            groupBefore = groupFirst      // and the old first node ends it
        }
        return dummy.next
    }
}
