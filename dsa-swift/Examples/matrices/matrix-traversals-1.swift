// Generated from src/dsa/content/lessons/matrices/matrix-traversals.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
]
let rows = grid.count
let columns = grid[0].count

var rowMajor: [Int] = []
for r in 0..<rows {
    for c in 0..<columns {
        rowMajor.append(grid[r][c])
    }
}

var columnMajor: [Int] = []
for c in 0..<columns {
    for r in 0..<rows {
        columnMajor.append(grid[r][c])
    }
}

print(rowMajor)
print(columnMajor)
