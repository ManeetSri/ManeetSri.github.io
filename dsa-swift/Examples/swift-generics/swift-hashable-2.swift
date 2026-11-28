// Generated from src/dsa/content/lessons/swift-generics/swift-hashable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Cell: Hashable {
    var row: Int
    var column: Int
}

var stepsTo: [Cell: Int] = [:]
stepsTo[Cell(row: 0, column: 0)] = 0
stepsTo[Cell(row: 1, column: 0)] = 1
stepsTo[Cell(row: 1, column: 1)] = 2

print(stepsTo[Cell(row: 1, column: 1)] ?? -1)
print(stepsTo[Cell(row: 9, column: 9)] ?? -1)
print(stepsTo.count)
