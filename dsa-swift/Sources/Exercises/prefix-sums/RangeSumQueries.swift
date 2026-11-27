// Problem: Range sum queries (M20 · 1D prefix sums and range queries)

public enum RangeSumQueries {
    /// Answers sums over ranges of a fixed array of integers.
    public struct Table {
        // Write your solution here, then run:
        // swift test --filter RangeSumQueriesTests
        // Add whatever private storage you need.

        /// Prepares the table for `values`. Aim for O(n).
        public init(_ values: [Int]) {}

        /// The sum of `values[start...end]`, inclusive at both ends. Aim for O(1).
        public func sum(from start: Int, through end: Int) -> Int {
            return 0
        }
    }
}
