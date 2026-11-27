// Problem: Rounding division for every Int (M15 · Floor and ceiling division, and overflow)

public enum RoundingDivision {
    /// ⌊a / b⌋ for any b ≠ 0, exact for every Int (except Int.min / -1). No Double.
    public static func floorQuotient(_ a: Int, _ b: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter RoundingDivisionTests
        return 0
    }

    /// ⌈a / b⌉ for any b ≠ 0, exact for every Int (except Int.min / -1). No Double.
    public static func ceilingQuotient(_ a: Int, _ b: Int) -> Int {
        return 0
    }

    /// The value in 0..<b equal to a − b × ⌊a / b⌋, for b ≥ 1. Must not overflow.
    public static func offset(_ a: Int, within b: Int) -> Int {
        return -1
    }
}
