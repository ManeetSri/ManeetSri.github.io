// Problem: Best price in the fewest runs (M28 · Exponential, jump, interpolation and ternary search)

public enum UnimodalArgmax {
    /// Returns the price in `range` where `profit` peaks. `profit` rises strictly to one peak, then falls
    /// strictly. Call it only inside `range`, and at most 2 × (bit length of range.count) + 2 times.
    public static func peak(in range: ClosedRange<Int>, profit: (Int) -> Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter UnimodalArgmaxTests
        return range.lowerBound - 1
    }
}
