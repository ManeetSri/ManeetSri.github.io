// Generated from src/dsa/content/lessons/divide-conquer/dc-closest-pair.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    let x: Int
    let y: Int
}

func squaredDistance(_ a: Point, _ b: Point) -> Int {
    let dx = a.x - b.x
    let dy = a.y - b.y
    return dx * dx + dy * dy
}

// Try every pair: n(n - 1)/2 distances
func closestBruteForce(_ points: [Point]) -> (Point, Point) {
    var best = (points[0], points[1])
    for i in points.indices {
        for j in (i + 1)..<points.count where squaredDistance(points[i], points[j]) < squaredDistance(best.0, best.1) {
            best = (points[i], points[j])
        }
    }
    return best
}

let points = [(2, 3), (12, 30), (40, 50), (5, 1), (12, 10), (3, 4)].map { Point(x: $0.0, y: $0.1) }
let (a, b) = closestBruteForce(points)
let squared = squaredDistance(a, b)
print("(\(a.x), \(a.y)) and (\(b.x), \(b.y)): squared distance \(squared), distance \((Double(squared).squareRoot() * 1_000).rounded() / 1_000)")
