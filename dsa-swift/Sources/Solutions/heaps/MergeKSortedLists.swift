// Reference solution: Merge k sorted lists. A min-heap holds the current head of every non-empty
// list, ordered by value. Pop the smallest, link it onto the result, and push the node after it.
// The heap never holds more than k nodes, so each of the N nodes costs O(log k): O(N log k) time,
// O(k) extra space, and the original nodes are reused.

import DSAKit

public enum MergeKSortedLists {
    public static func merge(_ lists: [ListNode?]) -> ListNode? {
        var heads = Heap(lists.compactMap { $0 }, areInIncreasingOrder: { $0.value < $1.value })
        let dummy = ListNode(0)
        var tail = dummy
        while let smallest = heads.pop() {
            tail.next = smallest
            tail = smallest
            if let next = smallest.next {
                heads.insert(next)
            }
        }
        tail.next = nil
        return dummy.next
    }
}
