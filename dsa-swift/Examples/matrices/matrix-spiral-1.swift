// Generated from src/dsa/content/lessons/matrices/matrix-spiral.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func spiralFill(rows: Int, columns: Int) -> [[Int]] {
    var grid = Array(repeating: Array(repeating: 0, count: columns), count: rows)
    var top = 0
    var bottom = rows - 1
    var left = 0
    var right = columns - 1
    var next = 1

    while top <= bottom && left <= right {
        for c in left...right {                                   // top row, rightwards
            grid[top][c] = next
            next += 1
        }
        top += 1

        if top <= bottom {
            for r in top...bottom {                               // right column, downwards
                grid[r][right] = next
                next += 1
            }
        }
        right -= 1

        if top <= bottom && left <= right {
            for c in stride(from: right, through: left, by: -1) { // bottom row, leftwards
                grid[bottom][c] = next
                next += 1
            }
            bottom -= 1
        }

        if left <= right && top <= bottom {
            for r in stride(from: bottom, through: top, by: -1) { // left column, upwards
                grid[r][left] = next
                next += 1
            }
            left += 1
        }
    }
    return grid
}

for row in spiralFill(rows: 4, columns: 4) {
    print(row)
}
print("3 × 5:")
for row in spiralFill(rows: 3, columns: 5) {
    print(row)
}
