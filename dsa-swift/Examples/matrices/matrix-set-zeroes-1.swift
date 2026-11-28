// Generated from src/dsa/content/lessons/matrices/matrix-set-zeroes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var grid = [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
]
let rows = grid.count
let columns = grid[0].count
for r in 0..<rows {
    for c in 0..<columns where grid[r][c] == 0 {
        for k in 0..<columns {
            grid[r][k] = 0
        }
        for k in 0..<rows {
            grid[k][c] = 0
        }
    }
}
for row in grid {
    print(row)
}
