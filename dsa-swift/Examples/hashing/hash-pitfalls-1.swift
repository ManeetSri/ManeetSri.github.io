// Generated from src/dsa/content/lessons/hashing/hash-pitfalls.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Cell: Hashable {
    var row: Int
    var column: Int
}

var start = Cell(row: 0, column: 0)
var visited: Set<Cell> = [start]
start.row = 5                                  // changes our copy only

print(visited.contains(Cell(row: 0, column: 0)))
print(visited.contains(start))
