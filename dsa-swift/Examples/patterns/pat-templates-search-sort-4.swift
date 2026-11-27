// Generated from src/dsa/content/lessons/patterns/pat-templates-search-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Three interval templates. Intervals are [start, end] pairs.

// 1. Merge: sort by start, then extend the last merged interval or start a new one
func merge(_ intervals: [[Int]]) -> [[Int]] {
    var merged: [[Int]] = []
    for interval in intervals.sorted(by: { $0[0] < $1[0] }) {
        if let last = merged.last, interval[0] <= last[1] {
            merged[merged.count - 1][1] = max(last[1], interval[1])   // overlaps: extend
        } else {
            merged.append(interval)
        }
    }
    return merged
}

// 2. Most non-overlapping: sort by end, keep each interval that starts after the last kept one ends
func mostNonOverlapping(_ intervals: [[Int]]) -> Int {
    var kept = 0
    var lastEnd = Int.min
    for interval in intervals.sorted(by: { $0[1] < $1[1] }) where interval[0] >= lastEnd {
        kept += 1                                 // touching ends are fine: [1, 3] then [3, 5]
        lastEnd = interval[1]
    }
    return kept                                   // fewest to remove: intervals.count - kept
}

// 3. Sweep line: the most intervals open at once (meeting rooms), half-open [start, end)
func mostAtOnce(_ intervals: [[Int]]) -> Int {
    var events: [(time: Int, change: Int)] = []
    for interval in intervals {
        events.append((interval[0], 1))
        events.append((interval[1], -1))
    }
    // At equal times, -1 sorts before +1: a meeting ending at 10 frees its room for one starting at 10
    events.sort { ($0.time, $0.change) < ($1.time, $1.change) }
    var open = 0
    var most = 0
    for event in events {
        open += event.change
        most = max(most, open)
    }
    return most
}

let talks = [[9, 11], [1, 3], [2, 6], [8, 10], [15, 18], [10, 12]]
print(merge(talks))
print(mostNonOverlapping(talks))
print(mostAtOnce(talks))
