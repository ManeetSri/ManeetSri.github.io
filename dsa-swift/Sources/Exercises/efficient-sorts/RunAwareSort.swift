// Problem: A sort that spots runs (M31 · Shell sort and Timsort ideas)

public enum RunAwareSort {
    /// Returns `items` sorted by `areInIncreasingOrder`, keeping equal elements in their original
    /// order (stable). Already-sorted input must cost at most n comparisons, and any input at most
    /// about n log₂ n. Don't use the standard library's sorts or DSAKit's.
    public static func sorted<Element>(
        _ items: [Element], by areInIncreasingOrder: (Element, Element) -> Bool
    ) -> [Element] {
        // Write your solution here, then run:
        // swift test --filter RunAwareSortTests
        return []
    }
}
