// Problem: Insertion sort for any collection (M30 · Generic sorts for Comparable)

public enum GenericInsertionSort {
    /// Sorts `items` in place with insertion sort, so that `areInIncreasingOrder` holds between
    /// every pair of neighbours that aren't equal. Works on any mutable, random-access collection,
    /// including slices whose first index isn't 0. The sort must be stable.
    /// Don't use the standard library's sort() or sorted(), or DSAKit's sorts.
    public static func sort<C>(
        _ items: inout C,
        by areInIncreasingOrder: (C.Element, C.Element) -> Bool
    ) where C: MutableCollection & RandomAccessCollection {
        // Write your solution here, then run:
        // swift test --filter GenericInsertionSortTests
    }
}
