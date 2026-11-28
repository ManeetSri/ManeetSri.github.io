// Generated from src/dsa/content/lessons/geometry/geo-polygons.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

/// Grid points strictly inside and on the boundary of a polygon with whole-number corners
func gridPoints(_ corners: [(x: Int, y: Int)]) -> (inside: Int, boundary: Int) {
    var twiceArea = 0
    var boundary = 0
    for i in corners.indices {
        let a = corners[i], b = corners[(i + 1) % corners.count]
        twiceArea += a.x * b.y - a.y * b.x
        boundary += gcd(abs(b.x - a.x), abs(b.y - a.y))
    }
    return ((abs(twiceArea) - boundary + 2) / 2, boundary)
}

print(gridPoints([(0, 0), (4, 0), (0, 4)]))
print(gridPoints([(0, 0), (6, 0), (6, 2), (2, 2), (2, 6), (0, 6)]))
print(gridPoints([(0, 0), (1_000_000, 0), (0, 1_000_000)]))
