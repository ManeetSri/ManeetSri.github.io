// Generated from src/dsa/content/lessons/matrices/matrix-set-zeroes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func spreadZeroes(_ grid: inout [[Int]]) {
    guard let columns = grid.first?.count else { return }
    var zeroRow = Array(repeating: false, count: grid.count)
    var zeroColumn = Array(repeating: false, count: columns)
    for r in grid.indices {
        for c in 0..<columns where grid[r][c] == 0 {
            zeroRow[r] = true
            zeroColumn[c] = true
        }
    }
    for r in grid.indices {
        for c in 0..<columns where zeroRow[r] || zeroColumn[c] {
            grid[r][c] = 0
        }
    }
}

var grid = [[1, 1, 1], [1, 0, 1], [1, 1, 1]]
spreadZeroes(&grid)
for row in grid {
    print(row)
}

var other = [[0, 2, 3, 0], [4, 5, 6, 7], [8, 9, 1, 2]]
spreadZeroes(&other)
for row in other {
    print(row)
}
