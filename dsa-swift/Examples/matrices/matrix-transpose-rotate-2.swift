// Generated from src/dsa/content/lessons/matrices/matrix-transpose-rotate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func transposeInPlace(_ grid: inout [[Int]]) {
    let n = grid.count
    for r in 0..<n {
        for c in (r + 1)..<n {           // only cells above the main diagonal
            let saved = grid[r][c]
            grid[r][c] = grid[c][r]
            grid[c][r] = saved
        }
    }
}

var square = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
transposeInPlace(&square)
for row in square {
    print(row)
}
