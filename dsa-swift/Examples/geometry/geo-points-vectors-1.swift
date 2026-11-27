// Generated from src/dsa/content/lessons/geometry/geo-points-vectors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point: Hashable {
    var x: Int
    var y: Int

    static func + (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (scale: Int, p: Point) -> Point {
        Point(x: scale * p.x, y: scale * p.y)
    }

    static prefix func - (p: Point) -> Point {
        Point(x: -p.x, y: -p.y)
    }
}

let a = Point(x: 1, y: 1)
let b = Point(x: 4, y: 3)
let move = b - a
print(move)
print(a + 2 * move)
print(-move)
print(a + move == b)
let visited: Set<Point> = [a, b, a + move]
print(visited.count)
