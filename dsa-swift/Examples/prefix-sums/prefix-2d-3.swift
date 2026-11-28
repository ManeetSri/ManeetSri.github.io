// Generated from src/dsa/content/lessons/prefix-sums/prefix-2d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let rows = 4
let columns = 5
var diff = Array(repeating: Array(repeating: 0, count: columns + 1), count: rows + 1)

func addToRegion(top: Int, left: Int, bottom: Int, right: Int, _ value: Int) {
    diff[top][left] += value
    diff[top][right + 1] -= value
    diff[bottom + 1][left] -= value
    diff[bottom + 1][right + 1] += value
}

addToRegion(top: 0, left: 1, bottom: 1, right: 3, 2)
addToRegion(top: 1, left: 2, bottom: 3, right: 4, 5)

// A 2D prefix sum over diff turns the corner marks into values
var grid = Array(repeating: Array(repeating: 0, count: columns), count: rows)
for r in 0..<rows {
    for c in 0..<columns {
        let above = r > 0 ? grid[r - 1][c] : 0
        let left = c > 0 ? grid[r][c - 1] : 0
        let aboveLeft = r > 0 && c > 0 ? grid[r - 1][c - 1] : 0
        grid[r][c] = diff[r][c] + above + left - aboveLeft
    }
}
for row in grid {
    print(row)
}
