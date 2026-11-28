// Problem: Count the loop steps (M14 · Counting operations)

public enum LoopStepCount {
    /// How many times `body` runs in `for i in 0..<n { for j in (i + 1)..<n { body } }`.
    /// Use a formula: don't run the loops.
    public static func pairChecks(_ n: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter LoopStepCountTests
        return 0
    }

    /// How many times `body` runs in:
    ///
    ///     var size = n
    ///     while size > 0 {
    ///         for _ in 0..<size { body }
    ///         size /= 2
    ///     }
    ///
    /// Take O(log n) steps or fewer: don't run the body loop.
    public static func shrinkingPasses(_ n: Int) -> Int {
        return 0
    }
}
