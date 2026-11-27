// Generated from src/dsa/content/lessons/matrices/matrix-traversals.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
]
let rows = grid.count
let columns = grid[0].count
var antiDiagonals = Array(repeating: [Int](), count: rows + columns - 1)
var diagonals = Array(repeating: [Int](), count: rows + columns - 1)
for r in 0..<rows {
    for c in 0..<columns {
        antiDiagonals[r + c].append(grid[r][c])
        diagonals[c - r + rows - 1].append(grid[r][c])
    }
}
print(antiDiagonals)
print(diagonals)
