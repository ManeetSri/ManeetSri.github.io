// Reference solution: Point in the plot. For each query, first check every edge for "on the boundary":
// collinear (cross product zero) and inside the edge's bounding box. Otherwise cast a ray to the right
// and count the edges it crosses; an odd count means inside. An edge counts only when exactly one of
// its ends is strictly above the point (the half-open rule), which handles rays through corners and
// along horizontal edges. Whether the crossing is to the right of the point is the sign of a cross
// product, so the test stays exact in Int with no division. O(n) per query, O(n · q) in all, O(q) space.

public enum PlotPointLocator {
    struct Point {
        var x: Int
        var y: Int
    }

    static func place(of p: Point, in polygon: [Point]) -> Int {
        var inside = false
        var a = polygon[polygon.count - 1]
        for b in polygon {
            // cross(b - a, p - a): positive when p is to the left of the edge a → b
            let cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
            if cross == 0 && min(a.x, b.x) <= p.x && p.x <= max(a.x, b.x)
                && min(a.y, b.y) <= p.y && p.y <= max(a.y, b.y) {
                return 0                                    // on this edge
            }
            if (a.y > p.y) != (b.y > p.y) {
                // The edge straddles the ray's line. Going up, it crosses to the right of p exactly
                // when p is on its left; going down, exactly when p is on its right.
                if (b.y > a.y) == (cross > 0) {
                    inside.toggle()
                }
            }
            a = b
        }
        return inside ? 1 : -1
    }

    public static func locate(_ plot: [[Int]], _ queries: [[Int]]) -> [Int] {
        let polygon = plot.map { Point(x: $0[0], y: $0[1]) }
        return queries.map { place(of: Point(x: $0[0], y: $0[1]), in: polygon) }
    }
}
