// Problem: Bulk bonus totals (M61 · Range updates, and range queries with two BITs)

public enum BulkBonusTotals {
    /// Desk i starts with `initial[i]` paid to it. Each operation is either `[0, left, right, amount]`,
    /// which pays `amount` more to every desk in `left...right`, or `[1, left, right]`, which asks for
    /// the total paid so far to the desks in `left...right`. Returns the answers to the questions, in
    /// order.
    public static func process(initial: [Int], operations: [[Int]]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter BulkBonusTotalsTests
        return []
    }
}
