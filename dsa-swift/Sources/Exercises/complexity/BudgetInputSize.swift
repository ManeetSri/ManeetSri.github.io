// Problem: The biggest input for a budget (M14 · Growth classes from O(1) to O(n!))

public enum BudgetInputSize {
    /// A growth class, with these step counts for input size n:
    /// linear n, linearithmic n × ⌊log₂ n⌋, quadratic n², cubic n³, exponential 2ⁿ, factorial n!.
    public enum Growth: CaseIterable {
        case linear, linearithmic, quadratic, cubic, exponential, factorial
    }

    /// The largest n ≥ 0 whose step count for `growth` is at most `budget` (1 ≤ budget ≤ 10¹²).
    public static func largestInput(for growth: Growth, budget: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter BudgetInputSizeTests
        return 0
    }
}
