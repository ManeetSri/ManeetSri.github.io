// Problem: Three recursive warm-ups (M17 · Warm-ups: factorial, power, digits, reverse)

public enum RecursionWarmups {
    // Write your solutions here, then run:
    // swift test --filter RecursionWarmupsTests

    /// Returns n, n − 1, …, 1, 0, 1, …, n for n ≥ 0. For example, `bounce(from: 2)` is [2, 1, 0, 1, 2].
    /// Write it recursively: one call should add its number both before and after the smaller call.
    public static func bounce(from n: Int) -> [Int] {
        return []
    }

    /// Returns `base` raised to `exponent` (exponent ≥ 0). Halve the exponent at each recursive call,
    /// so the number of calls grows with log₂ of the exponent.
    public static func power(_ base: Int, _ exponent: Int) -> Int {
        return 0
    }

    /// Returns how many times `character` appears in `text`. Recurse over an index into
    /// `Array(text)`, without loops and without the built-in counting helpers.
    public static func count(of character: Character, in text: String) -> Int {
        return 0
    }
}
