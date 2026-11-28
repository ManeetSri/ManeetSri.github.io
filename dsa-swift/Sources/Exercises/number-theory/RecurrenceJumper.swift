// Problem: Jump along a recurrence (M66 · Matrix exponentiation)

public enum RecurrenceJumper {
    /// a(0)…a(k − 1) are `initial`, and a(i) = c₁·a(i − 1) + c₂·a(i − 2) + … + c_k·a(i − k) for i ≥ k,
    /// where `coefficients` is [c₁, …, c_k]. Returns a(n) modulo 1,000,000,007, from 0 to 1,000,000,006.
    /// 0 ≤ n ≤ 10¹⁸, 1 ≤ k ≤ 10, and every input value is between −10⁹ and 10⁹.
    public static func term(_ n: Int, coefficients: [Int], initial: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter RecurrenceJumperTests
        return 0
    }
}
