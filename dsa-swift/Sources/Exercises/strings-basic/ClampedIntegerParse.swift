// Problem: String to integer, clamped (M23 · String to integer, with every edge case)

public enum ClampedIntegerParse {
    /// Reads an integer from the start of `text`: skips leading spaces, reads an optional + or -,
    /// then digits until anything else. Returns 0 if there are no digits, and clamps to
    /// Int.min...Int.max instead of overflowing.
    public static func parse(_ text: String) -> Int {
        // Write your solution here, then run:
        // swift test --filter ClampedIntegerParseTests
        return 0
    }
}
