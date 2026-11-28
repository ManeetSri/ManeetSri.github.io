// Reference solution: Fence corner posts. Andrew's monotone chain. Sort the trees by (x, y) and drop
// duplicates. Build the lower hull left to right: before adding a point, pop the last point while the
// last two and the new one fail to make a strict left turn (orientation ≤ 0), which removes right turns
// and collinear middle points alike. Build the upper hull the same way from right to left, then join
// the two, dropping each chain's last point because it starts the other chain. The result is
// counterclockwise from the smallest (x, y), which is exactly the order asked for. Each point is pushed
// and popped at most once per chain, so after the O(n log n) sort the chains take O(n). O(n) space.

public enum FenceCornerPosts {
    struct Point: Comparable {
        var x: Int
        var y: Int

        static func < (lhs: Point, rhs: Point) -> Bool {
            (lhs.x, lhs.y) < (rhs.x, rhs.y)
        }
    }

    /// The cross product of b - a and c - a: positive when a → b → c turns left
    static func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    public static func corners(_ trees: [[Int]]) -> [[Int]] {
        var points: [Point] = []
        for p in trees.map({ Point(x: $0[0], y: $0[1]) }).sorted() where points.last != p {
            points.append(p)                            // sorted, so duplicates are neighbours
        }
        if points.count < 3 {
            return points.map { [$0.x, $0.y] }         // nothing, one point, or the two ends of a line
        }

        func chain(_ ordered: [Point]) -> [Point] {
            var hull: [Point] = []
            for p in ordered {
                while hull.count >= 2 && orientation(hull[hull.count - 2], hull[hull.count - 1], p) <= 0 {
                    hull.removeLast()
                }
                hull.append(p)
            }
            return hull
        }
        let lower = chain(points)
        let upper = chain(points.reversed())
        let hull = lower.dropLast() + upper.dropLast()
        return hull.map { [$0.x, $0.y] }
    }
}
