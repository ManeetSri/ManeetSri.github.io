// Problem: First reading at least a target, length unknown (M28 · Exponential, jump, interpolation and ternary search)

public enum GallopingLowerBound {
    /// Returns the first index whose reading is at least `target`, or nil if every reading is smaller.
    /// The readings are in non-decreasing order; `value(i)` returns nil once `i` is past the end, and
    /// you don't know where the end is. Use O(log p) reads, where p is the answer's position.
    public static func firstIndex(atLeast target: Int, reading value: (Int) -> Int?) -> Int? {
        // Write your solution here, then run:
        // swift test --filter GallopingLowerBoundTests
        return -1
    }
}
