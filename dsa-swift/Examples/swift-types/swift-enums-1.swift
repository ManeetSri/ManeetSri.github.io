// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Direction {
    case north
    case east
    case south
    case west
}

let heading = Direction.east
var next: Direction = .south
next = .west

switch heading {
case .north, .south:
    print("Moving vertically")
case .east, .west:
    print("Moving horizontally")
}
print(next)
