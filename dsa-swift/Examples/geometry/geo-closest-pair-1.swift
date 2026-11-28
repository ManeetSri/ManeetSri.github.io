// Generated from src/dsa/content/lessons/geometry/geo-closest-pair.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int
}

/// The largest r with r * r ≤ value
func integerSquareRoot(_ value: Int) -> Int {
    var root = Int(Double(value).squareRoot())
    while root * root > value { root -= 1 }
    while (root + 1) * (root + 1) <= value { root += 1 }
    return root
}

/// The first index of `window`, sorted by (y, x), whose entry is at least `key`
func lowerBound(_ window: [(Int, Int)], _ key: (Int, Int)) -> Int {
    var low = 0, high = window.count
    while low < high {
        let mid = (low + high) / 2
        if window[mid] < key { low = mid + 1 } else { high = mid }
    }
    return low
}

func squaredDistance(_ a: Point, _ b: Point) -> Int {
    (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
}

/// The smallest squared distance between two of at least two points
func closestPair(_ input: [Point]) -> Int {
    let points = input.sorted { ($0.x, $0.y) < ($1.x, $1.y) }
    var best = squaredDistance(points[0], points[1])
    var window: [(Int, Int)] = []          // (y, x) of the points near the sweep line, sorted
    var left = 0
    for p in points {
        if best == 0 { return 0 }          // two points on one spot: nothing beats that
        // Points at least √best to the left can't beat best, for p or for anything after it
        while (p.x - points[left].x) * (p.x - points[left].x) >= best {
            window.remove(at: lowerBound(window, (points[left].y, points[left].x)))
            left += 1
        }
        // Only points within √best above or below can beat best
        let reach = integerSquareRoot(best)
        var i = lowerBound(window, (p.y - reach, Int.min))
        var checked: [String] = []
        while i < window.count && window[i].0 <= p.y + reach {
            let q = Point(x: window[i].1, y: window[i].0)
            checked.append("(\(q.x), \(q.y))")
            best = min(best, squaredDistance(p, q))
            i += 1
        }
        window.insert((p.y, p.x), at: lowerBound(window, (p.y, p.x)))
        print("(\(p.x), \(p.y)): checked \(checked.isEmpty ? "nothing" : checked.joined(separator: " ")), best \(best)")
    }
    return best
}

let points = [Point(x: 1, y: 9), Point(x: 2, y: 3), Point(x: 4, y: 7), Point(x: 5, y: 1),
              Point(x: 7, y: 5), Point(x: 8, y: 8), Point(x: 9, y: 2), Point(x: 10, y: 6)]
print("closest:", closestPair(points))
