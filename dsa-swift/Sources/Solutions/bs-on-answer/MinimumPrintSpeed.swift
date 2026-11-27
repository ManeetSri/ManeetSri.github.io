// Reference solution: Slowest printer speed. Binary search on the answer: at speed s, a job of p pages
// takes ⌈p / s⌉ minutes, and the total never grows as s grows, so "finishes within the limit" is
// false … false, true … true. Search 1…max(jobs) (at the largest job's size every job takes exactly one
// minute) for the first speed that works. O(n log max) time, O(1) space.

public enum MinimumPrintSpeed {
    public static func slowestSpeed(jobs: [Int], minutes: Int) -> Int {
        var low = 1
        var high = jobs.max()!                       // always works, because minutes ≥ jobs.count
        while low < high {
            let mid = low + (high - low) / 2
            if finishes(jobs, speed: mid, within: minutes) {
                high = mid                           // mid works: the answer is mid or slower
            } else {
                low = mid + 1                        // mid is too slow
            }
        }
        return low
    }

    /// True if every job is printed within `limit` minutes at `speed` pages per minute.
    private static func finishes(_ jobs: [Int], speed: Int, within limit: Int) -> Bool {
        var total = 0
        for pages in jobs {
            total += (pages + speed - 1) / speed     // ⌈pages / speed⌉ without Double
            if total > limit { return false }        // stop early: already too slow
        }
        return true
    }
}
