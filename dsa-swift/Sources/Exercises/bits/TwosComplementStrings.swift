// Problem: Two's complement strings (M16 · Binary and two's complement)

public enum TwosComplementStrings {
    /// The `width`-character two's complement pattern of `value` (1 ≤ width ≤ 64; value fits).
    public static func pattern(of value: Int, width: Int) -> String {
        // Write your solution here, then run:
        // swift test --filter TwosComplementStringsTests
        return ""
    }

    /// The value stored in a pattern of 1 to 64 bits, whose leftmost bit is worth −2^(width − 1).
    public static func value(of pattern: String) -> Int {
        return 0
    }

    /// The pattern with every bit flipped and 1 added, same width, dropping any carry out.
    public static func negated(_ pattern: String) -> String {
        return ""
    }
}
