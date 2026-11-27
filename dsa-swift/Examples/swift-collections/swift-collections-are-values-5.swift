// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var board = [[0, 0], [0, 0]]
let saved = board
board[0][1] = 9
print(saved)
print(board)
