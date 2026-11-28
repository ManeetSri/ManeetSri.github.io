// Generated from src/dsa/content/lessons/geometry/geo-segment-intersection.mdx. Edit the lesson, then run
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

func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
    let cross = (b - a).cross(c - a)
    return cross > 0 ? 1 : (cross < 0 ? -1 : 0)
}

/// For p already known to be collinear with a and b: is it between them?
func within(_ p: Point, _ a: Point, _ b: Point) -> Bool {
    min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x) && min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y)
}

/// Do segments ab and cd share at least one point?
func segmentsIntersect(_ a: Point, _ b: Point, _ c: Point, _ d: Point) -> Bool {
    let o1 = orientation(a, b, c), o2 = orientation(a, b, d)
    let o3 = orientation(c, d, a), o4 = orientation(c, d, b)
    if o1 * o2 < 0 && o3 * o4 < 0 { return true }       // a proper crossing
    if o1 == 0 && within(c, a, b) { return true }       // c lies on ab
    if o2 == 0 && within(d, a, b) { return true }       // d lies on ab
    if o3 == 0 && within(a, c, d) { return true }       // a lies on cd
    if o4 == 0 && within(b, c, d) { return true }       // b lies on cd
    return false
}

let cases: [(String, [Point])] = [
    ("crossing", [Point(0, 0), Point(4, 4), Point(0, 4), Point(4, 0)]),
    ("T-junction", [Point(0, 0), Point(4, 0), Point(2, 0), Point(2, 3)]),
    ("shared end", [Point(0, 0), Point(4, 0), Point(4, 0), Point(6, 2)]),
    ("near miss", [Point(0, 0), Point(4, 4), Point(5, 0), Point(5, 9)]),
    ("parallel", [Point(0, 0), Point(4, 0), Point(0, 1), Point(4, 1)]),
    ("collinear, overlapping", [Point(0, 0), Point(4, 0), Point(3, 0), Point(7, 0)]),
    ("collinear, with a gap", [Point(0, 0), Point(4, 0), Point(5, 0), Point(7, 0)]),
    ("a single point on ab", [Point(0, 0), Point(4, 4), Point(1, 1), Point(1, 1)]),
]
for (label, p) in cases {
    print("\(label): \(segmentsIntersect(p[0], p[1], p[2], p[3]))")
}
