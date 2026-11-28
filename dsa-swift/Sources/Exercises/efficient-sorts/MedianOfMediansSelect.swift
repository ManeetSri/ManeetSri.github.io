// Problem: Selection with a guaranteed deadline (M31 · Median of medians)

public enum MedianOfMediansSelect {
    /// The median-of-medians pivot of `numbers`: split into groups of 5 in order (the last may be
    /// smaller), take each group's element at index count / 2 once sorted, and return the value at
    /// sorted index medians.count / 2 of those medians. O(n) in the worst case.
    public static func pivot(of numbers: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter MedianOfMediansSelectTests
        return 0
    }

    /// The value that would be at 0-based `index` if `numbers` were sorted, found with quickselect
    /// using `pivot(of:)`. Deterministic, and O(n) in the worst case.
    public static func value(atSortedIndex index: Int, in numbers: [Int]) -> Int {
        return 0
    }
}
