// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The first index whose end is at least `value`. Ends are sorted in a non-overlapping list.
func firstEnding(atOrAfter value: Int, in intervals: [[Int]]) -> Int {
    var low = 0
    var high = intervals.count             // search the half-open range low..<high
    while low < high {
        let mid = low + (high - low) / 2
        if intervals[mid][1] < value {
            low = mid + 1
        } else {
            high = mid
        }
    }
    return low
}

let calendar = [[1, 2], [3, 5], [6, 7], [8, 10], [12, 16]]
print(firstEnding(atOrAfter: 4, in: calendar))
print(firstEnding(atOrAfter: 11, in: calendar))
print(firstEnding(atOrAfter: 20, in: calendar))
