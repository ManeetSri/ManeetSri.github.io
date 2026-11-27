// Generated from src/dsa/content/lessons/geometry/geo-segment-intersection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

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

/// The single point where segments ab and cd cross, or nil if they're parallel or the lines
/// cross outside either segment
func crossingPoint(_ a: Point, _ b: Point, _ c: Point, _ d: Point) -> (x: Double, y: Double)? {
    let r = b - a, s = d - c, q = c - a
    var denominator = r.cross(s)
    if denominator == 0 { return nil }                      // parallel: no single crossing
    var tTop = q.cross(s), uTop = q.cross(r)
    if denominator < 0 {
        (denominator, tTop, uTop) = (-denominator, -tTop, -uTop)
    }
    // t = tTop / denominator and u = uTop / denominator must both be between 0 and 1
    guard 0 <= tTop && tTop <= denominator && 0 <= uTop && uTop <= denominator else { return nil }
    let t = Double(tTop) / Double(denominator)              // the only division, at the very end
    return (Double(a.x) + t * Double(r.x), Double(a.y) + t * Double(r.y))
}

let tests = [
    (Point(x: 0, y: 0), Point(x: 3, y: 3), Point(x: 0, y: 2), Point(x: 4, y: 0)),
    (Point(x: 0, y: 0), Point(x: 5, y: 2), Point(x: 1, y: 3), Point(x: 4, y: -1)),
    (Point(x: 0, y: 0), Point(x: 2, y: 2), Point(x: 3, y: 0), Point(x: 4, y: -1)),
    (Point(x: 0, y: 0), Point(x: 4, y: 0), Point(x: 1, y: 0), Point(x: 6, y: 0)),
]
for (a, b, c, d) in tests {
    if let p = crossingPoint(a, b, c, d) {
        print(String(format: "(%.3f, %.3f)", p.x, p.y))
    } else {
        print("no single crossing")
    }
}
