// Generated from src/dsa/content/lessons/geometry/geo-points-vectors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func dot(_ other: Point) -> Int {
        x * other.x + y * other.y
    }
}

// A triangle has a right angle at b when the two sides leaving b are perpendicular
func isRightAngle(at b: Point, _ a: Point, _ c: Point) -> Bool {
    (a - b).dot(c - b) == 0
}
print(isRightAngle(at: Point(x: 0, y: 0), Point(x: 3, y: 0), Point(x: 0, y: 4)))
print(isRightAngle(at: Point(x: 1, y: 1), Point(x: 3, y: 2), Point(x: 0, y: 3)))
print(isRightAngle(at: Point(x: 1, y: 1), Point(x: 3, y: 2), Point(x: 0, y: 4)))

// A guard stands at (2, 2), facing along (1, 1). Is each visitor in front of the guard, or behind?
let guardPosition = Point(x: 2, y: 2)
let facing = Point(x: 1, y: 1)
for visitor in [Point(x: 5, y: 3), Point(x: 0, y: 1), Point(x: 3, y: 1)] {
    let d = facing.dot(visitor - guardPosition)
    print(visitor.x, visitor.y, d > 0 ? "in front" : (d < 0 ? "behind" : "level"))
}
