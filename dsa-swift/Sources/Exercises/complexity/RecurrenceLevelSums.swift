// Problem: Recurrences, level by level (M14 · The Master theorem)

public enum RecurrenceLevelSums {
    /// Which part of the recursion tree dominates: compare a with bᵈ.
    public enum MasterCase: Equatable {
        case rootDominates, balanced, leavesDominate
    }

    /// T(n) = a · T(n / b) + nᵈ with T(1) = 1, exactly, for n a power of b. Don't run the recursion.
    public static func work(n: Int, a: Int, b: Int, d: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter RecurrenceLevelSumsTests
        return 0
    }

    /// The Master theorem case for a · T(n / b) + nᵈ.
    public static func predictedCase(a: Int, b: Int, d: Int) -> MasterCase {
        return .balanced
    }
}
