// Reference solution: Segment contact. Four orientation tests, each reduced to its sign (-1, 0 or 1)
// before any multiplying, so nothing overflows. If each segment's ends lie strictly on opposite sides
// of the other's line, it's a proper crossing: one point. If all four orientations are zero, every end
// lies on one line (this also covers segments that are single points), so the segments are intervals
// on that line: order points by (x, y), which runs along any line, and intersect the two intervals.
// Otherwise they share at most one point, and they share one exactly when an end of one lies on the
// other. O(1) time and space.

public enum SegmentContact {
    public enum Contact: Equatable, Sendable {
        case disjoint
        case point
        case overlap
    }

    struct Point: Comparable {
        var x: Int
        var y: Int

        static func < (lhs: Point, rhs: Point) -> Bool {
            (lhs.x, lhs.y) < (rhs.x, rhs.y)
        }
    }

    /// The sign of the cross product of b - a and c - a: 1 for a left turn, -1 for right, 0 collinear.
    static func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
        let cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        return cross > 0 ? 1 : (cross < 0 ? -1 : 0)
    }

    /// For p collinear with a and b: is p between them? Then it's inside their bounding box.
    static func within(_ p: Point, _ a: Point, _ b: Point) -> Bool {
        min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x) && min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y)
    }

    public static func contact(_ first: [[Int]], _ second: [[Int]]) -> Contact {
        let a = Point(x: first[0][0], y: first[0][1]), b = Point(x: first[1][0], y: first[1][1])
        let c = Point(x: second[0][0], y: second[0][1]), d = Point(x: second[1][0], y: second[1][1])
        let o1 = orientation(a, b, c), o2 = orientation(a, b, d)
        let o3 = orientation(c, d, a), o4 = orientation(c, d, b)

        if o1 * o2 < 0 && o3 * o4 < 0 {
            return .point                                   // a proper crossing
        }
        if o1 == 0 && o2 == 0 && o3 == 0 && o4 == 0 {
            // All on one line: intersect the intervals [min, max] in (x, y) order
            let low = max(min(a, b), min(c, d))
            let high = min(max(a, b), max(c, d))
            if low < high { return .overlap }
            return low == high ? .point : .disjoint
        }
        let touches = (o1 == 0 && within(c, a, b)) || (o2 == 0 && within(d, a, b))
            || (o3 == 0 && within(a, c, d)) || (o4 == 0 && within(b, c, d))
        return touches ? .point : .disjoint
    }
}
