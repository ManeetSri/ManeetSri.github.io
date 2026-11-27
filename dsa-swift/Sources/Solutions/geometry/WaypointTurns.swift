// Reference solution: Waypoint turns. At each interior waypoint, compare the direction you arrive in
// with the direction you leave in. The sign of their cross product says left (positive), right
// (negative) or neither (zero); when it's zero the two directions are parallel, and the sign of the dot
// product separates straight on (same way) from a U-turn (opposite ways). Everything stays in Int:
// coordinates up to 10⁹ make each difference at most 2 × 10⁹, so each product is at most 4 × 10¹⁸ and
// the cross or dot product at most 8 × 10¹⁸, just inside Int.max. O(n) time, O(n) space for the answer.

public enum WaypointTurns {
    struct Point {
        var x: Int
        var y: Int

        static func - (lhs: Point, rhs: Point) -> Point {
            Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
        }

        func cross(_ other: Point) -> Int {
            x * other.y - y * other.x
        }

        func dot(_ other: Point) -> Int {
            x * other.x + y * other.y
        }
    }

    public static func turns(_ waypoints: [[Int]]) -> String {
        guard waypoints.count >= 3 else { return "" }
        let points = waypoints.map { Point(x: $0[0], y: $0[1]) }
        var letters: [Character] = []
        letters.reserveCapacity(points.count - 2)
        for i in 1..<(points.count - 1) {
            let arriving = points[i] - points[i - 1]
            let leaving = points[i + 1] - points[i]
            let cross = arriving.cross(leaving)
            if cross > 0 {
                letters.append("L")
            } else if cross < 0 {
                letters.append("R")
            } else {
                letters.append(arriving.dot(leaving) > 0 ? "S" : "U")
            }
        }
        return String(letters)
    }
}
