// Generated from src/dsa/content/lessons/swift-types/swift-value-vs-reference.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ScoreValue {
    var points = 0
}

class ScoreObject {
    var points = 0
}

let board = ScoreObject()
board.points = 10
board.points += 5
print(board.points)

var other = ScoreValue()
other.points = 3
print(other.points)
