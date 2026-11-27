// Generated from src/dsa/content/lessons/intervals/iv-non-overlapping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Keep each interval that fits after the last one kept, in the order given
func keptGreedily(_ sorted: [[Int]]) -> [[Int]] {
    var kept: [[Int]] = []
    for interval in sorted {
        if let last = kept.last, interval[0] < last[1] {
            continue                                   // overlaps the last one kept: skip it
        }
        kept.append(interval)
    }
    return kept
}

let talks = [[1, 10], [2, 4], [5, 7], [8, 9]]
print("by start:", keptGreedily(talks.sorted { $0[0] < $1[0] }))
print("by end:  ", keptGreedily(talks.sorted { $0[1] < $1[1] }))
