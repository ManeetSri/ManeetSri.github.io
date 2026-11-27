// Generated from src/dsa/content/lessons/geometry/geo-cross-orientation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    func cross(_ other: Point) -> Int {
        x * other.y - y * other.x
    }
}

let a = Point(x: 3, y: 0)
let others = [("(1, 2)", Point(x: 1, y: 2)), ("(2, -1)", Point(x: 2, y: -1)),
              ("(6, 0)", Point(x: 6, y: 0)), ("(-3, 0)", Point(x: -3, y: 0))]
for (label, b) in others {
    print("b = \(label): cross(a, b) = \(a.cross(b)), cross(b, a) = \(b.cross(a))")
}
