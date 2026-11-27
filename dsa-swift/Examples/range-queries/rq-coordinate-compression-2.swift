// Generated from src/dsa/content/lessons/range-queries/rq-coordinate-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Total length covered by at least k half-open intervals [start, end), with huge coordinates
func lengthCovered(atLeast k: Int, _ intervals: [(start: Int, end: Int)]) -> Int {
    // 1. Compress: every endpoint, sorted and deduplicated
    let points = Array(Set(intervals.flatMap { [$0.start, $0.end] })).sorted()
    var rankOf: [Int: Int] = [:]
    for (rank, point) in points.enumerated() { rankOf[point] = rank }

    // 2. A difference array over the compressed points: +1 where an interval starts, -1 where it ends
    var change = [Int](repeating: 0, count: points.count)
    for interval in intervals {
        change[rankOf[interval.start]!] += 1
        change[rankOf[interval.end]!] -= 1
    }

    // 3. Sweep: between points[i] and points[i + 1], the coverage is constant
    var covering = 0
    var total = 0
    for i in points.indices.dropLast() {
        covering += change[i]
        if covering >= k {
            total += points[i + 1] - points[i]        // the real length, from the real coordinates
        }
    }
    return total
}

let broadcasts = [(start: 10, end: 50), (start: 30, end: 1_000_000), (start: 40, end: 60), (start: 999_990, end: 2_000_000_000)]
print(lengthCovered(atLeast: 1, broadcasts))
print(lengthCovered(atLeast: 2, broadcasts))
print(lengthCovered(atLeast: 3, broadcasts))
