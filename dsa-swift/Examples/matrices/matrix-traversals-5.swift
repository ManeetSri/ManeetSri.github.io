// Generated from src/dsa/content/lessons/matrices/matrix-traversals.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
]
var snake: [Int] = []
for (r, row) in grid.enumerated() {
    if r % 2 == 0 {
        snake.append(contentsOf: row)
    } else {
        snake.append(contentsOf: row.reversed())
    }
}
print(snake)
