// Reference solution: Split a trail into days. Binary search on the longest day. For a limit, walk
// greedily: keep adding stages to today until the next one would go over, then start a new day. If the
// greedy plan needs at most `days` days, the limit works: any day with two or more stages can be split
// to use up the spare days without making any day longer, so "at most" and "exactly" agree as long as
// there are at least `days` stages. O(n log(sum)) time, O(1) space.

public enum TrailDaySplit {
    public static func shortestLongestDay(stages: [Int], days: Int) -> Int {
        guard days <= stages.count else { return -1 }    // someone would walk nothing
        var low = stages.max()!                          // the longest stage happens on some day
        var high = stages.reduce(0, +)                   // one day walks the whole trail
        while low < high {
            let mid = low + (high - low) / 2
            if daysNeeded(stages, limit: mid) <= days {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    /// Days the greedy plan needs when no day may exceed `limit`. Needs limit ≥ the longest stage.
    private static func daysNeeded(_ stages: [Int], limit: Int) -> Int {
        var days = 1
        var today = 0
        for length in stages {
            if today + length > limit {
                days += 1
                today = 0
            }
            today += length
        }
        return days
    }
}
