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

func windingNumber(of p: Point, in polygon: [Point]) -> Int {
    var winding = 0
    for i in polygon.indices {
        let a = polygon[i], b = polygon[(i + 1) % polygon.count]
        let turn = (b - a).cross(p - a)
        if a.y <= p.y && b.y > p.y && turn > 0 { winding += 1 }     // upward, p on its left
        if a.y > p.y && b.y <= p.y && turn < 0 { winding -= 1 }     // downward, p on its right
    }
    return winding
}

func oddCrossings(of p: Point, in polygon: [Point]) -> Bool {
    var inside = false
    for i in polygon.indices {
        let a = polygon[i], b = polygon[(i + 1) % polygon.count]
        let turn = (b - a).cross(p - a)
        if (a.y > p.y) != (b.y > p.y) && (b.y > a.y ? turn > 0 : turn < 0) {
            inside.toggle()
        }
    }
    return inside
}

// A five-pointed star drawn in one stroke, visiting every second corner of a pentagon
let star = [Point(0, 10), Point(-6, -8), Point(10, 3), Point(-10, 3), Point(6, -8)]
for p in [Point(0, 0), Point(0, 7), Point(12, 0)] {
    let parity = oddCrossings(of: p, in: star) ? "inside" : "outside"
    print("(\(p.x), \(p.y)): winding number \(windingNumber(of: p, in: star)), crossings say \(parity)")
}
