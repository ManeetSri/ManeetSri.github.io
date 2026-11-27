// Generated from src/dsa/content/lessons/geometry/geo-polygons.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    func cross(_ other: Point) -> Int {
        x * other.y - y * other.x
    }
}

extension Point {
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
}

/// Twice the signed area: positive if the corners run counterclockwise, negative if clockwise
func twiceSignedArea(_ corners: [Point]) -> Int {
    var total = 0
    for i in corners.indices {
        total += corners[i].cross(corners[(i + 1) % corners.count])
    }
    return total
}

/// The area itself, from twice the area: a whole number or a half
func describe(_ twiceArea: Int) -> String {
    let doubled = abs(twiceArea)
    return "\(doubled / 2)" + (doubled % 2 == 1 ? ".5" : "")
}

let lShape = [Point(0, 0), Point(6, 0), Point(6, 2), Point(2, 2), Point(2, 6), Point(0, 6)]
let triangle = [Point(0, 0), Point(5, 0), Point(2, 3)]
print(twiceSignedArea(lShape), describe(twiceSignedArea(lShape)))
print(twiceSignedArea(lShape.reversed()), describe(twiceSignedArea(lShape.reversed())))
print(twiceSignedArea(triangle), describe(twiceSignedArea(triangle)))
