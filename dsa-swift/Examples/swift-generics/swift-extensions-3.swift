// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int
}

extension Point {
    init(both value: Int) {
        self.init(x: value, y: value)
    }

    func manhattanDistance(to other: Point) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}

let a = Point(x: 1, y: 2)
let b = Point(both: 5)
print(a.manhattanDistance(to: b))
