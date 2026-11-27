// Generated from src/dsa/content/lessons/swift-collections/swift-2d-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let rows = 3
let cols = 4
var board = Array(repeating: Array(repeating: 0, count: cols), count: rows)
board[1][2] = 7

for row in board {
    print(row)
}
