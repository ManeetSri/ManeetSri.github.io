// Problem: Find a profit loop (M44 · Bellman–Ford and negative cycles)

public enum ProfitLoopFinder {
    /// Traders are numbered 0..<traderCount, and each trade [from, to, cost] can be made one way at that
    /// cost (a negative cost is a profit). Returns a loop of distinct traders [t0, t1, …, tk] with trades
    /// t0 → t1 → … → tk → t0 whose costs add up to less than zero, or [] if no such loop exists.
    public static func findLoop(traderCount: Int, trades: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter ProfitLoopFinderTests
        return []
    }
}
