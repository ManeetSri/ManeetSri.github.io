// Generated from src/dsa/content/lessons/swift-types/swift-observers-static.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    static let origin = Point(x: 0, y: 0)
    static var created = 0

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        Point.created += 1
    }
}

let a = Point(x: 3, y: 4)
let b = Point(x: -1, y: 2)
print(Point.origin)
print(Point.created)
print(a.x + b.x)
