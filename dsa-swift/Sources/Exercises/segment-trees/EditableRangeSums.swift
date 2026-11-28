// Problem: Range sums with edits (M60 · Build, query and update)

public enum EditableRangeSums {
    /// Answers sums over ranges of an array of integers that keeps being edited.
    public struct Table {
        // Write your solution here, then run:
        // swift test --filter EditableRangeSumsTests
        // Add whatever private storage you need.

        /// Prepares the table for `values`. Aim for O(n).
        public init(_ values: [Int]) {}

        /// Changes `values[index]` to `value`. Aim for O(log n).
        public mutating func update(at index: Int, to value: Int) {}

        /// The sum of `values[start...end]`, inclusive at both ends, with every edit so far applied.
        /// Aim for O(log n).
        public func sum(from start: Int, through end: Int) -> Int {
            return 0
        }
    }
}
