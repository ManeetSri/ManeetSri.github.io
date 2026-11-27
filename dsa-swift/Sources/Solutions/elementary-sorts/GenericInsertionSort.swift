// Reference solution: Insertion sort for any collection. The usual shifting insertion sort, but
// every index moves with startIndex, endIndex, index(after:) and index(before:), so it works on
// slices whose indexes don't start at 0. It shifts only while the key must come strictly before
// its left neighbour, which keeps it stable. O(n + d) time for d inversions, O(1) extra space.

public enum GenericInsertionSort {
    public static func sort<C>(
        _ items: inout C,
        by areInIncreasingOrder: (C.Element, C.Element) -> Bool
    ) where C: MutableCollection & RandomAccessCollection {
        guard !items.isEmpty else { return }
        var next = items.index(after: items.startIndex)     // everything before `next` is sorted
        while next != items.endIndex {
            let key = items[next]
            var gap = next
            while gap != items.startIndex {
                let before = items.index(before: gap)
                guard areInIncreasingOrder(key, items[before]) else { break }
                items[gap] = items[before]                    // shift it one place right
                gap = before
            }
            items[gap] = key
            items.formIndex(after: &next)
        }
    }
}
