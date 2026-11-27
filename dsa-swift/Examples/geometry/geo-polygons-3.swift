// Generated from src/dsa/content/lessons/geometry/geo-polygons.mdx. Edit the lesson, then run
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

extension Point {
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
}

/// 1 inside, 0 on the boundary, -1 outside
func locate(_ p: Point, in polygon: [Point]) -> Int {
    var inside = false
    for i in polygon.indices {
        let a = polygon[i], b = polygon[(i + 1) % polygon.count]
        let turn = (b - a).cross(p - a)                      // positive: p is left of a → b
        if turn == 0 && min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x)
            && min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y) {
            return 0                                         // on this edge
        }
        if (a.y > p.y) != (b.y > p.y) {                      // the edge straddles the ray's line
            let crossesToTheRight = b.y > a.y ? turn > 0 : turn < 0
            if crossesToTheRight {
                inside.toggle()
            }
        }
    }
    return inside ? 1 : -1
}

let uShape = [Point(0, 0), Point(6, 0), Point(6, 5), Point(4, 5), Point(4, 2), Point(2, 2), Point(2, 5), Point(0, 5)]
for p in [Point(1, 1), Point(3, 3), Point(5, 3), Point(3, 2), Point(3, 5), Point(-1, 2), Point(6, 5)] {
    let place = ["outside", "on the boundary", "inside"][locate(p, in: uShape) + 1]
    print("(\(p.x), \(p.y)) is \(place)")
}
