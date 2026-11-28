// Generated from src/dsa/content/lessons/prefix-sums/prefix-2d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [3, 0, 1, 4],
    [5, 6, 3, 2],
    [1, 2, 0, 1],
]
let rows = grid.count
let columns = grid[0].count
var prefix = Array(repeating: Array(repeating: 0, count: columns + 1), count: rows + 1)
for r in 0..<rows {
    for c in 0..<columns {
        prefix[r + 1][c + 1] = grid[r][c] + prefix[r][c + 1] + prefix[r + 1][c] - prefix[r][c]
    }
}
for row in prefix {
    print(row)
}
