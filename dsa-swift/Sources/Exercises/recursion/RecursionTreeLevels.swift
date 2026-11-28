// Problem: Recursion trees, level by level (M17 · Recursion trees and their complexity)

public enum RecursionTreeLevels {
    /// The number of calls on each level of fib(n)'s recursion tree, top level first (0 ≤ n ≤ 80).
    /// Don't run the recursion.
    public static func fibonacciLevels(_ n: Int) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter RecursionTreeLevelsTests
        return []
    }

    /// The number of calls on each level of the halves sum over n items, top level first
    /// (1 ≤ n ≤ 10¹⁸). A range of s ≥ 2 items calls itself on ⌈s/2⌉ and ⌊s/2⌋ items.
    public static func halvesLevels(_ n: Int) -> [Int] {
        return []
    }
}
