// Problem: Read off the growth (M49 · Applying the Master theorem)

public enum RecurrenceGrowthReader {
    /// For T(n) = a·T(n/b) + n^d·(log n)^k, returns p and q such that T(n) = Θ(n^p · (log n)^q).
    public static func solve(a: Int, b: Int, d: Int, k: Int) -> (exponent: Double, logPower: Int) {
        // Write your solution here, then run:
        // swift test --filter RecurrenceGrowthReaderTests
        return (0, 0)
    }
}
