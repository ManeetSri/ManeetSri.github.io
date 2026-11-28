// Problem: Sort five with seven comparisons (M31 · The Ω(n log n) lower bound)

public enum FewestComparisonSort {
    /// Returns `values` (at most 5 of them) sorted by `isLess`, calling `isLess` at most ⌈log₂ n!⌉
    /// times for every input: 0, 0, 1, 3, 5 and 7 calls for 0 to 5 values. Compare values only by
    /// calling `isLess`.
    public static func sorted(_ values: [Int], by isLess: (Int, Int) -> Bool) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter FewestComparisonSortTests
        return []
    }
}
