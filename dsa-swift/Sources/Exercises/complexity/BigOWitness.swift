// Problem: Find the n₀ (M14 · Big-O, Big-Ω and Big-Θ)

public enum BigOWitness {
    /// The smallest n₀ ≥ 1 with a·n + b ≤ c·n for every n ≥ n₀, or nil if there's none.
    /// Answer in O(1).
    public static func linearStart(a: Int, b: Int, c: Int) -> Int? {
        // Write your solution here, then run:
        // swift test --filter BigOWitnessTests
        return 0
    }

    /// The smallest n₀ ≥ 1 with a·n² + b·n + k ≤ c·n² for every n ≥ n₀, or nil if there's none.
    public static func quadraticStart(a: Int, b: Int, k: Int, c: Int) -> Int? {
        return 0
    }
}
