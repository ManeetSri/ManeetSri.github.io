// Reference solution: Ranges from bit patterns. A signed type gives half its patterns to negatives
// and half to zero and the positives; an unsigned type counts up from zero. O(1) time and space.

public enum BitPatternRange {
    public static func signedMin(patterns: Int) -> Int {
        -(patterns / 2)
    }

    public static func signedMax(patterns: Int) -> Int {
        patterns / 2 - 1 // zero takes one of the non-negative half's patterns
    }

    public static func unsignedMax(patterns: Int) -> Int {
        patterns - 1 // all patterns, counting up from zero
    }
}
