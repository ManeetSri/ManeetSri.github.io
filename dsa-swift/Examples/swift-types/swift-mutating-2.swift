// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    mutating func reset() {
        self = Point(x: 0, y: 0)
    }
}

var cursor = Point(x: 7, y: 9)
cursor.reset()
print(cursor)
