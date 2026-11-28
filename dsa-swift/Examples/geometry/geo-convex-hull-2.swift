// Generated from src/dsa/content/lessons/geometry/geo-convex-hull.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point: Comparable {
    var x: Int
    var y: Int

    static func < (lhs: Point, rhs: Point) -> Bool {
        (lhs.x, lhs.y) < (rhs.x, rhs.y)
    }

    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func cross(_ other: Point) -> Int {
        x * other.y - y * other.x
    }
}

extension Point: CustomStringConvertible {
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }

    var description: String { "(\(x), \(y))" }
}

func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
    (b - a).cross(c - a)
}

/// The hull counterclockwise from the smallest (x, y). With keepCollinear, points on an edge between
/// two corners are included too.
func convexHull(_ input: [Point], keepCollinear: Bool) -> [Point] {
    var points: [Point] = []
    for p in input.sorted() where points.last != p {
        points.append(p)
    }
    if points.count < 3 {
        return points
    }
    if keepCollinear && points.allSatisfy({ orientation(points[0], points[1], $0) == 0 }) {
        return points                        // one straight line: every point is on the boundary
    }
    func chain(_ ordered: [Point]) -> [Point] {
        var stack: [Point] = []
        for p in ordered {
            while stack.count >= 2 {
                let turn = orientation(stack[stack.count - 2], stack[stack.count - 1], p)
                guard turn < 0 || (turn == 0 && !keepCollinear) else { break }
                stack.removeLast()
            }
            stack.append(p)
        }
        return stack
    }
    return chain(points).dropLast() + chain(points.reversed()).dropLast()
}

let points = [Point(2, 2), Point(4, 0), Point(1, 0), Point(6, 2), Point(3, 3), Point(5, 5),
              Point(0, 3), Point(3, 0), Point(4, 2), Point(2, 5), Point(4, 5)]
print(convexHull(points, keepCollinear: false))
print(convexHull(points, keepCollinear: true))
print(convexHull([Point(0, 0), Point(2, 2), Point(1, 1), Point(1, 1)], keepCollinear: true))
