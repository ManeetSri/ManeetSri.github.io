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

var mostChecks = 0                                 // the most strip comparisons made for any one point

// The smallest squared distance in points[low..<high], which arrive sorted by x.
// Like merge sort, each call leaves its range sorted by y, so the strip comes out in y order for free.
func closest(_ points: inout [Point], _ buffer: inout [Point], _ low: Int, _ high: Int) -> Int {
    if high - low <= 3 {                           // tiny ranges: try every pair, then sort by y
        var best = Int.max
        for i in low..<high {
            for j in (i + 1)..<high {
                best = min(best, squaredDistance(points[i], points[j]))
            }
        }
        points[low..<high].sort { $0.y < $1.y }
        return best
    }
    let mid = low + (high - low) / 2
    let lineX = points[mid].x                      // read it before the calls reorder the range
    var best = min(closest(&points, &buffer, low, mid), closest(&points, &buffer, mid, high))

    // Merge the two halves by y, exactly as merge sort does
    for index in low..<high {
        buffer[index] = points[index]
    }
    var left = low
    var right = mid
    for write in low..<high {
        if right == high || (left < mid && buffer[left].y <= buffer[right].y) {
            points[write] = buffer[left]
            left += 1
        } else {
            points[write] = buffer[right]
            right += 1
        }
    }

    // The strip: points closer to the dividing line than the best distance so far, in y order
    var strip: [Point] = []
    for point in points[low..<high] where (point.x - lineX) * (point.x - lineX) < best {
        strip.append(point)
    }
    for i in strip.indices {
        var j = i + 1
        var checks = 0
        while j < strip.count && (strip[j].y - strip[i].y) * (strip[j].y - strip[i].y) < best {
            best = min(best, squaredDistance(strip[i], strip[j]))
            j += 1
            checks += 1
        }
        mostChecks = max(mostChecks, checks)
    }
    return best
}

func closestPair(_ input: [Point]) -> Int {
    var points = input.sorted { ($0.x, $0.y) < ($1.x, $1.y) }
    var buffer = points
    return closest(&points, &buffer, 0, points.count)
}

func closestBruteForce(_ points: [Point]) -> Int {
    var best = Int.max
    for i in points.indices {
        for j in (i + 1)..<points.count {
            best = min(best, squaredDistance(points[i], points[j]))
        }
    }
    return best
}

let small = [(2, 3), (12, 30), (40, 50), (5, 1), (12, 10), (3, 4)].map { Point(x: $0.0, y: $0.1) }
print("small example:", closestPair(small))

// A seeded generator, so the "random" points are the same on every run
var seed: UInt64 = 65
func nextRandom(_ range: ClosedRange<Int>) -> Int {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return range.lowerBound + Int((seed >> 33) % UInt64(range.count))
}

var agree = 0
for _ in 0..<200 {
    let points = (0..<nextRandom(2...60)).map { _ in Point(x: nextRandom(-50...50), y: nextRandom(-50...50)) }
    if closestPair(points) == closestBruteForce(points) {
        agree += 1
    }
}
print("agrees with brute force on \(agree) of 200 random sets")

mostChecks = 0
let many = (0..<100_000).map { _ in Point(x: nextRandom(0...1_000_000_000), y: nextRandom(0...1_000_000_000)) }
print("100,000 points: closest squared distance \(closestPair(many)), most strip checks for one point: \(mostChecks)")
