// Generated from src/dsa/content/lessons/matrices/matrix-transpose-rotate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func rotatedClockwise(_ grid: [[Int]]) -> [[Int]] {
    let rows = grid.count
    let columns = grid.first?.count ?? 0
    var result = Array(repeating: Array(repeating: 0, count: rows), count: columns)
    for r in 0..<rows {
        for c in 0..<columns {
            result[c][rows - 1 - r] = grid[r][c]
        }
    }
    return result
}

let wide = [[1, 2, 3], [4, 5, 6]]
for row in rotatedClockwise(wide) {
    print(row)
}
