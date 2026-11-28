// Reference solution: Gap between two pipes. Decide with integers, measure with Doubles at the end.
// First an exact orientation test: if the segments touch or cross, the answer is exactly 0. Otherwise
// the closest pair of points always includes an end of one segment, so the answer is the smallest of
// four point-to-segment distances. For a point p and segment ab, the dot product of p - a with b - a
// says whether p projects before a, past b, or onto the segment; in the last case the distance is
// |cross(b - a, p - a)| / |b - a|, a single division of exact integers. O(1) time and space.

public enum PipeGap {
    struct Point {
        var x: Int
        var y: Int

        static func - (lhs: Point, rhs: Point) -> Point {
            Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
        }

        func cross(_ other: Point) -> Int { x * other.y - y * other.x }
        func dot(_ other: Point) -> Int { x * other.x + y * other.y }
        var length: Double { Double(dot(self)).squareRoot() }
    }

    static func sign(_ value: Int) -> Int {
        value > 0 ? 1 : (value < 0 ? -1 : 0)
    }

    /// For p collinear with a and b: is p between them?
    static func within(_ p: Point, _ a: Point, _ b: Point) -> Bool {
        min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x) && min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y)
    }

    static func touch(_ a: Point, _ b: Point, _ c: Point, _ d: Point) -> Bool {
        let o1 = sign((b - a).cross(c - a)), o2 = sign((b - a).cross(d - a))
        let o3 = sign((d - c).cross(a - c)), o4 = sign((d - c).cross(b - c))
        if o1 * o2 < 0 && o3 * o4 < 0 {
            return true
        }
        return (o1 == 0 && within(c, a, b)) || (o2 == 0 && within(d, a, b))
            || (o3 == 0 && within(a, c, d)) || (o4 == 0 && within(b, c, d))
    }

    static func distance(from p: Point, to a: Point, _ b: Point) -> Double {
        let ab = b - a, ap = p - a
        let along = ap.dot(ab)
        if along <= 0 {
            return ap.length                              // p projects at or before a
        }
        if along >= ab.dot(ab) {
            return (p - b).length                         // at or past b
        }
        return Double(abs(ab.cross(ap))) / ab.length      // onto the segment: height of a parallelogram
    }

    public static func shortestGap(_ first: [[Int]], _ second: [[Int]]) -> Double {
        let a = Point(x: first[0][0], y: first[0][1]), b = Point(x: first[1][0], y: first[1][1])
        let c = Point(x: second[0][0], y: second[0][1]), d = Point(x: second[1][0], y: second[1][1])
        if touch(a, b, c, d) {
            return 0
        }
        return min(distance(from: a, to: c, d), distance(from: b, to: c, d),
                   distance(from: c, to: a, b), distance(from: d, to: a, b))
    }
}
