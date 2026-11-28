// Generated from src/dsa/content/lessons/swift-generics/swift-hashable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Cell: Hashable {
    var row: Int
    var column: Int
}

var visited: Set<Cell> = []
visited.insert(Cell(row: 0, column: 0))
visited.insert(Cell(row: 0, column: 1))
visited.insert(Cell(row: 0, column: 0))

print(visited.count)
print(visited.contains(Cell(row: 0, column: 1)))
print(visited.contains(Cell(row: 5, column: 5)))
