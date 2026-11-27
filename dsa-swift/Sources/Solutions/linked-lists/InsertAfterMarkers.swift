// Reference solution: A new node after every marker. One walk: at a marker, link a new node in after it
// (grabbing the rest of the list before changing `next`), then jump past the new node so it's never
// taken for a marker. O(n) time, O(1) extra space apart from the new nodes.

import DSAKit

public enum InsertAfterMarkers {
    public static func insert(_ value: Int, afterEvery marker: Int, in head: ListNode?) {
        var current = head
        while let node = current {
            if node.value == marker {
                let added = ListNode(value, next: node.next)   // grab the rest of the list first
                node.next = added
                current = added.next                           // skip the node just added
            } else {
                current = node.next
            }
        }
    }
}
