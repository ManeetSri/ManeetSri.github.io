// Problem: Fares within a price window (M62 · Offline query processing)

public enum FareWindowCounts {
    /// `fares[i]` is the fare on day i. For each query `[left, right, low, high]`, returns how many days
    /// in `left...right` have a fare with `low ≤ fare ≤ high`, in the order the queries are given.
    ///
    /// All queries are known up front: aim for O((n + q) log n) by answering them offline.
    public static func counts(fares: [Int], queries: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter FareWindowCountsTests
        return []
    }
}
