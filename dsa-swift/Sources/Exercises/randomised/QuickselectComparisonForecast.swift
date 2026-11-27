// Problem: Forecast quickselect's work (M67 · Randomised quickselect)

public enum QuickselectComparisonForecast {
    /// The exact expected number of comparisons randomised quickselect (uniform pivot, Lomuto
    /// partition) makes to find rank `t` (from 0) among `n` distinct values. O(n).
    public static func expectedComparisons(count n: Int, targetRank t: Int) -> Double {
        // Write your solution here, then run:
        // swift test --filter QuickselectComparisonForecastTests
        return 0
    }

    /// The exact expected number of partitions (rounds) it makes for the same search. O(n).
    public static func expectedPartitions(count n: Int, targetRank t: Int) -> Double {
        return 0
    }
}
