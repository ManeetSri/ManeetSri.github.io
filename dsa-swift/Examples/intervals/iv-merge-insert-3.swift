// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func merge(_ intervals: [[Int]]) -> [[Int]] {
    let sorted = intervals.sorted { $0[0] < $1[0] }
    var merged: [[Int]] = []
    for interval in sorted {
        if let last = merged.last, interval[0] <= last[1] {
            merged[merged.count - 1][1] = max(last[1], interval[1])   // overlap: stretch the last one
        } else {
            merged.append(interval)                                   // a gap: start a new one
        }
        print(interval, "->", merged)
    }
    return merged
}

print(merge([[8, 10], [1, 3], [2, 6], [15, 18], [6, 7], [17, 20]]))
