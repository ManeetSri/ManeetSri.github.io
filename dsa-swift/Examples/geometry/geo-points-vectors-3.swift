// Generated from src/dsa/content/lessons/geometry/geo-points-vectors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

struct Point {
    var x: Int
    var y: Int

    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func dot(_ other: Point) -> Int { x * other.x + y * other.y }
    var squaredLength: Int { dot(self) }
    var length: Double { Double(squaredLength).squareRoot() }
}

let home = Point(x: 0, y: 0)
let cafes = [Point(x: 4, y: 7), Point(x: -6, y: 5), Point(x: 8, y: -1)]
// Comparing squared distances needs no square roots, and stays exact
let nearest = cafes.min { ($0 - home).squaredLength < ($1 - home).squaredLength }!
print(nearest, (nearest - home).squaredLength)
print(String(format: "%.4f", (nearest - home).length))

// The distance from p to the segment from a to b
func distance(from p: Point, toSegmentFrom a: Point, to b: Point) -> Double {
    let ab = b - a
    let along = (p - a).dot(ab)
    if along <= 0 { return (p - a).length }                  // the foot is at or before a
    if along >= ab.squaredLength { return (p - b).length }   // at or past b
    let t = Double(along) / Double(ab.squaredLength)
    let dx = Double(p.x) - (Double(a.x) + t * Double(ab.x))  // p minus its foot
    let dy = Double(p.y) - (Double(a.y) + t * Double(ab.y))
    return (dx * dx + dy * dy).squareRoot()
}
let a = Point(x: 0, y: 0), b = Point(x: 6, y: 0)
for p in [Point(x: 2, y: 3), Point(x: -3, y: 4), Point(x: 7, y: 1)] {
    print(String(format: "%.4f", distance(from: p, toSegmentFrom: a, to: b)))
}
