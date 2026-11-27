// Generated from src/dsa/content/lessons/swift-types-operators/swift-tuples-typealias.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

typealias GridPosition = (row: Int, col: Int)
let start: GridPosition = (row: 0, col: 0)
let goal: GridPosition = (row: 4, col: 7)
print(goal.row - start.row, goal.col - start.col)

typealias Score = Int
let myScore: Score = 10
let bonus: Int = 5
print(myScore + bonus)
