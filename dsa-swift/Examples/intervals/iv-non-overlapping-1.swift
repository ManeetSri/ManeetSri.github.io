// Generated from src/dsa/content/lessons/intervals/iv-non-overlapping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minRemovals(_ intervals: [[Int]]) -> Int {
    let sorted = intervals.sorted { $0[1] < $1[1] }     // earliest end first
    var removals = 0
    var lastEnd = Int.min                                // the end of the last interval kept
    for interval in sorted {
        if interval[0] >= lastEnd {                      // half-open: touching is fine
            lastEnd = interval[1]
            print("keep  ", interval)
        } else {
            removals += 1
            print("remove", interval)
        }
    }
    return removals
}

print(minRemovals([[1, 3], [2, 4], [3, 5], [1, 8], [6, 7], [5, 9]]))
