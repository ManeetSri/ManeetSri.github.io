// Problem: Will it overflow? (M02 · Overflow traps and overflow operators)

public enum OverflowCheck {
    /// Returns true if `a + b` doesn't fit in an Int. Must never crash.
    public static func additionOverflows(_ a: Int, _ b: Int) -> Bool {
        // Write your solution here, then run:
        // swift test --filter OverflowCheckTests
        return false
    }

    /// Returns true if `a * b` doesn't fit in an Int. Must never crash.
    public static func multiplicationOverflows(_ a: Int, _ b: Int) -> Bool {
        return false
    }
}
