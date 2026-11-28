// Generated from src/dsa/content/lessons/swift-types-operators/swift-tuples-typealias.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let position = (row: 2, col: 3)
let up = (row: -1, col: 0)
let next = (row: position.row + up.row, col: position.col + up.col)
print(next)
