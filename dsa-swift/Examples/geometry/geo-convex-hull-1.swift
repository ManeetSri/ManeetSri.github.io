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

/// One chain of Andrew's algorithm: pop until the last two points and p turn strictly left
func chain(_ ordered: [Point]) -> [Point] {
    var stack: [Point] = []
    for p in ordered {
        while stack.count >= 2 && orientation(stack[stack.count - 2], stack[stack.count - 1], p) <= 0 {
            stack.removeLast()
        }
        stack.append(p)
    }
    return stack
}

/// The corners of the convex hull, counterclockwise from the smallest (x, y)
func convexHull(_ input: [Point]) -> [Point] {
    var points: [Point] = []
    for p in input.sorted() where points.last != p {
        points.append(p)                     // sorted, so duplicates are neighbours
    }
    if points.count < 3 {
        return points
    }
    let lower = chain(points)
    let upper = chain(points.reversed())
    print("lower:", lower)
    print("upper:", upper)
    return lower.dropLast() + upper.dropLast()
}

let points = [Point(2, 2), Point(4, 0), Point(1, 0), Point(6, 2), Point(3, 3), Point(5, 5),
              Point(0, 3), Point(3, 0), Point(4, 2), Point(2, 5), Point(4, 5)]
print("hull:", convexHull(points))
