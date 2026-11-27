// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insert(_ newInterval: [Int], into intervals: [[Int]]) -> [[Int]] {
    var result: [[Int]] = []
    var merged = newInterval
    var i = 0
    // 1. Everything that ends before the new interval starts
    while i < intervals.count && intervals[i][1] < merged[0] {
        result.append(intervals[i])
        i += 1
    }
    // 2. Everything that starts at or before its end overlaps it: absorb them
    while i < intervals.count && intervals[i][0] <= merged[1] {
        merged = [min(merged[0], intervals[i][0]), max(merged[1], intervals[i][1])]
        i += 1
    }
    result.append(merged)
    // 3. Everything after it, unchanged
    while i < intervals.count {
        result.append(intervals[i])
        i += 1
    }
    return result
}

let calendar = [[1, 2], [3, 5], [6, 7], [8, 10], [12, 16]]
print(insert([4, 8], into: calendar))
print(insert([0, 0], into: calendar))
print(insert([0, 20], into: calendar))
print(insert([5, 6], into: [[1, 2], [3, 5], [6, 7]]))
