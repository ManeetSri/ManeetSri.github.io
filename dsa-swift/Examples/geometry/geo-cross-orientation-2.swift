// Generated from src/dsa/content/lessons/geometry/geo-cross-orientation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func cross(_ other: Point) -> Int {
        x * other.y - y * other.x
    }
}

/// 1 if a → b → c turns left (counterclockwise), -1 if it turns right, 0 if the three are collinear
func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
    let cross = (b - a).cross(c - a)
    return cross > 0 ? 1 : (cross < 0 ? -1 : 0)
}

let a = Point(x: 0, y: 0), b = Point(x: 4, y: 2)
for c in [Point(x: 1, y: 3), Point(x: 5, y: 0), Point(x: 8, y: 4), Point(x: -2, y: -1), Point(x: 2, y: 2)] {
    let side = ["right of", "on", "left of"][orientation(a, b, c) + 1]
    print("(\(c.x), \(c.y)) is \(side) the line through a and b")
}
