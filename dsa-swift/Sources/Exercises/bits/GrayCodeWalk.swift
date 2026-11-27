// Problem: Walk the Gray code (M16 · Gray code and UInt64 bitsets)

public enum GrayCodeWalk {
    /// All 2^width Gray codes, i ^ (i >> 1) for i = 0, 1, 2, …
    public static func sequence(width: Int) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter GrayCodeWalkTests
        return []
    }

    /// The step i whose Gray code is `code`.
    public static func step(ofCode code: Int) -> Int {
        return -1
    }

    /// The total of each subset of `prices`, visited in Gray code order (item j is in the subset at
    /// step i when bit j of i ^ (i >> 1) is 1). One addition or subtraction per step.
    public static func subsetTotals(_ prices: [Int]) -> [Int] {
        return []
    }
}
