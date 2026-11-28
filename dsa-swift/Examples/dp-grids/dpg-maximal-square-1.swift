// Generated from src/dsa/content/lessons/dp-grids/dpg-maximal-square.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let field = [
    [1, 0, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1],
    [1, 1, 1, 1, 0],
]
let rows = field.count, cols = field[0].count

// side[r + 1][c + 1]: the largest all-ones square whose bottom-right corner is (r, c).
// A border of zeros above and to the left means no special cases.
var side = Array(repeating: Array(repeating: 0, count: cols + 1), count: rows + 1)
var largest = 0
for r in 0..<rows {
    for c in 0..<cols where field[r][c] == 1 {
        side[r + 1][c + 1] = 1 + min(side[r][c + 1], side[r + 1][c], side[r][c])   // above, left, diagonal
        largest = max(largest, side[r + 1][c + 1])
    }
}
for row in side.dropFirst() {
    print(Array(row.dropFirst()))
}
print("largest side", largest, "so area", largest * largest)
