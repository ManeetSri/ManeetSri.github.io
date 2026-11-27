// Problem: How many singers to watch first (M67 · Online vs offline algorithms)

public enum SecretaryCutoffPlanner {
    /// The index the plan casts: the first i ≥ r whose score beats every earlier score, or nil.
    public static func hire(scores: [Int], watch r: Int) -> Int? {
        // Write your solution here, then run:
        // swift test --filter SecretaryCutoffPlannerTests
        return -1
    }

    /// The exact probability that watching r of n singers, then casting the first who beats them all,
    /// casts the best singer, over uniformly random arrival orders. O(n).
    public static func successChance(candidates n: Int, watch r: Int) -> Double {
        return -1
    }

    /// The r in 0...n with the largest success chance (the smallest if several tie). O(n).
    public static func bestWatchCount(candidates n: Int) -> Int {
        return -1
    }
}
