// Generated from src/dsa/content/lessons/geometry/geo-cross-orientation.mdx. Edit the lesson, then run
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

func orientation(_ a: Point, _ b: Point, _ c: Point) -> Int {
    let cross = (b - a).cross(c - a)
    return cross > 0 ? 1 : (cross < 0 ? -1 : 0)
}

/// For a polygon that doesn't cross itself: are all its turns the same way?
func isConvex(_ corners: [Point]) -> Bool {
    var sawLeft = false
    var sawRight = false
    let n = corners.count
    for i in 0..<n {
        let turn = orientation(corners[i], corners[(i + 1) % n], corners[(i + 2) % n])
        if turn > 0 { sawLeft = true }
        if turn < 0 { sawRight = true }
    }
    return !(sawLeft && sawRight)
}

let square = [Point(x: 0, y: 0), Point(x: 4, y: 0), Point(x: 4, y: 4), Point(x: 0, y: 4)]
let arrowhead = [Point(x: 0, y: 0), Point(x: 4, y: 2), Point(x: 0, y: 4), Point(x: 1, y: 2)]
let withStraight = [Point(x: 0, y: 0), Point(x: 2, y: 0), Point(x: 4, y: 0), Point(x: 2, y: 3)]
print(isConvex(square), isConvex(arrowhead), isConvex(withStraight))
