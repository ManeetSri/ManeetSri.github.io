// Generated from src/dsa/content/lessons/swift-generics/swift-hashable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Cell: Hashable {
    var row: Int
    var column: Int
}

let path = "RRDLUR"
var position = Cell(row: 0, column: 0)
var seen: Set<Cell> = [position]
var firstRevisit: Cell?

for move in path {
    switch move {
    case "U": position.row -= 1
    case "D": position.row += 1
    case "L": position.column -= 1
    default: position.column += 1
    }
    if !seen.insert(position).inserted && firstRevisit == nil {
        firstRevisit = position
    }
}

print("Different cells:", seen.count)
if let cell = firstRevisit {
    print("First revisit: (\(cell.row), \(cell.column))")
}
