// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Direction {
    case north, east, south, west

    var turnedRight: Direction {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    var step: (row: Int, column: Int) {
        switch self {
        case .north: return (-1, 0)
        case .east: return (0, 1)
        case .south: return (1, 0)
        case .west: return (0, -1)
        }
    }

    mutating func turnRight() {
        self = turnedRight
    }
}

var facing = Direction.north
var row = 2
var column = 2
for _ in 0..<4 {
    row += facing.step.row
    column += facing.step.column
    facing.turnRight()
}
print("Ended at (\(row), \(column)) facing \(facing)")
