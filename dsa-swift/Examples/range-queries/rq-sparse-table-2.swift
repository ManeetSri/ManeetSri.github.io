// Generated from src/dsa/content/lessons/range-queries/rq-sparse-table.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A sparse table for range minimums: O(n log n) to build, O(1) per query
struct MinSparseTable {
    private var table: [[Int]]
    private var floorLog: [Int]              // floorLog[x] = ⌊log₂ x⌋

    init(_ values: [Int]) {
        let n = values.count
        floorLog = [Int](repeating: 0, count: n + 1)
        if n >= 2 {
            for x in 2...n {
                floorLog[x] = floorLog[x / 2] + 1
            }
        }
        table = [values]
        var j = 1
        while (1 << j) <= n {
            let previous = table[j - 1]
            let half = 1 << (j - 1)
            table.append((0...(n - (1 << j))).map { min(previous[$0], previous[$0 + half]) })
            j += 1
        }
    }

    /// The smallest value in values[left...right]
    func minimum(_ left: Int, _ right: Int) -> Int {
        let j = floorLog[right - left + 1]                       // the largest 2^j that fits
        return min(table[j][left], table[j][right - (1 << j) + 1])
    }
}

let prices = [7, 2, 9, 4, 8, 1, 6, 3]
let rmq = MinSparseTable(prices)
for (left, right) in [(0, 0), (2, 4), (1, 6), (2, 7), (6, 7)] {
    print("min of \(left)...\(right):", rmq.minimum(left, right))
}
