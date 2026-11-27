// Problem: Peak stack frames (M14 · Space complexity and the recursion stack)

public enum PeakStackFrames {
    /// The most frames alive at once during `sumRange(1, n)`, the range-halving sum.
    /// Don't run the recursion: answer in O(log n).
    public static func rangeSumFrames(_ n: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter PeakStackFramesTests
        return 0
    }

    /// The most frames alive at once during `trim(n)`, which calls `trim(n / 3)` then `trim(n - 2)`
    /// and stops when n ≤ 1. Don't run the recursion.
    public static func trimFrames(_ n: Int) -> Int {
        return 0
    }
}
