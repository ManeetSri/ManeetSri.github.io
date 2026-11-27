// Problem: The odometer's potential (M14 · Accounting and potential methods)

public enum OdometerPotential {
    /// The total number of digit changes over the first `n` increments of a base-`b` odometer
    /// starting at 0. Don't simulate: take O(log n) steps.
    public static func totalChanges(increments n: Int, base b: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter OdometerPotentialTests
        return 0
    }

    /// Each increment's amortised cost, actual + Φ after − Φ before, where Φ counts the digits
    /// showing b − 1.
    public static func amortisedCosts(increments n: Int, base b: Int) -> [Int] {
        return []
    }
}
