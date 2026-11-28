// Generated from src/dsa/content/lessons/dp-grids/dpg-maximal-square.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One row of sides, plus the diagonal value saved before it's overwritten
func squareStats(_ field: [[Int]]) -> (largestArea: Int, squares: Int) {
    let cols = field[0].count
    var side = Array(repeating: 0, count: cols + 1)   // side[c + 1] is column c; side[0] stays 0
    var largest = 0
    var squares = 0
    for row in field {
        var diagonal = 0                              // the previous row's value one column to the left
        for c in 0..<cols {
            let above = side[c + 1]
            side[c + 1] = row[c] == 1 ? 1 + min(above, side[c], diagonal) : 0
            diagonal = above
            largest = max(largest, side[c + 1])
            squares += side[c + 1]          // a side-k corner is the corner of k squares: sizes 1...k
        }
    }
    return (largest * largest, squares)
}

let field = [[1, 0, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 1], [1, 1, 1, 1, 0]]
print(squareStats(field))
print(squareStats([[1, 1], [1, 1]]))
print(squareStats([[0, 0, 0]]))
