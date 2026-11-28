// Reference solution: Power of two check. A power of two has exactly one set bit, so clearing the
// lowest set bit leaves 0. `n > 0` rules out 0 and negatives, and short-circuits before Int.min - 1
// could overflow. O(1) time and space.

public enum PowerOfTwoCheck {
    public static func isPowerOfTwo(_ n: Int) -> Bool {
        n > 0 && n & (n - 1) == 0
    }
}
