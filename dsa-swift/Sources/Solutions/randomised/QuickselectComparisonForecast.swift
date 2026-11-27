// Reference solution: Forecast quickselect's work. Ranks a < b are compared with probability
// 2 / (span length), where the span runs from min(a, t) to max(b, t); rank j is a pivot with probability
// 1 / (|j − t| + 1). Linearity of expectation adds these up. Grouping the pairs by the distance that sets
// their span (one side of t, the other side, or straddling t) turns the O(n²) pair sum into three O(n)
// loops. O(n) time, O(1) space.

public enum QuickselectComparisonForecast {
    public static func expectedComparisons(count n: Int, targetRank t: Int) -> Double {
        var total = 0.0
        // a < b ≤ t: span t − a + 1, with t − a choices of b; t ≤ a < b: span b − t + 1, b − t choices of a
        for d in stride(from: 1, through: t, by: 1) {
            total += 2.0 * Double(d) / Double(d + 1)
        }
        for d in stride(from: 1, through: n - 1 - t, by: 1) {
            total += 2.0 * Double(d) / Double(d + 1)
        }
        // a < t < b: the span is the pair's own distance d = b − a
        for d in stride(from: 2, through: n - 1, by: 1) {
            let low = max(0, t - d + 1)
            let high = min(t - 1, n - 1 - d)
            if high >= low {
                total += 2.0 * Double(high - low + 1) / Double(d + 1)
            }
        }
        return total
    }

    public static func expectedPartitions(count n: Int, targetRank t: Int) -> Double {
        var total = 0.0
        for j in 0..<n {
            total += 1.0 / Double(abs(j - t) + 1)
        }
        return total
    }
}
