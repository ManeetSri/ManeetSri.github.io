// Generated from src/dsa/content/lessons/geometry/geo-line-sweep.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A segment tree over compressed y slabs. Each node knows how many rectangles cover its whole range
/// and how much of its range is covered by anything.
struct CoverTree {
    let ys: [Int]                       // slab i is ys[i]..<ys[i + 1]
    var cover: [Int]
    var covered: [Int]

    init(ys: [Int]) {
        self.ys = ys
        cover = [Int](repeating: 0, count: 4 * max(ys.count - 1, 1))
        covered = cover
    }

    /// The total covered length: what the root knows
    var coveredLength: Int { covered[1] }

    /// Adds `change` to the cover of slabs from..<to
    mutating func update(_ from: Int, _ to: Int, _ change: Int) {
        update(node: 1, lo: 0, hi: ys.count - 1, from, to, change)
    }

    private mutating func update(node: Int, lo: Int, hi: Int, _ from: Int, _ to: Int, _ change: Int) {
        if to <= lo || hi <= from { return }                // no overlap
        if from <= lo && hi <= to {
            cover[node] += change                           // the whole node: just count it
        } else {
            let mid = (lo + hi) / 2
            update(node: 2 * node, lo: lo, hi: mid, from, to, change)
            update(node: 2 * node + 1, lo: mid, hi: hi, from, to, change)
        }
        if cover[node] > 0 {
            covered[node] = ys[hi] - ys[lo]                 // covered all the way across
        } else if hi - lo == 1 {
            covered[node] = 0                               // a leaf with nothing on it
        } else {
            covered[node] = covered[2 * node] + covered[2 * node + 1]
        }
    }
}

func coveredArea(_ rectangles: [[Int]]) -> Int {
    let solid = rectangles.filter { $0[0] < $0[2] && $0[1] < $0[3] }
    guard !solid.isEmpty else { return 0 }
    let ys = Array(Set(solid.flatMap { [$0[1], $0[3]] })).sorted()
    var slabOf: [Int: Int] = [:]
    for (index, y) in ys.enumerated() {
        slabOf[y] = index
    }
    var events: [(x: Int, from: Int, to: Int, change: Int)] = []
    for r in solid {
        events.append((r[0], slabOf[r[1]]!, slabOf[r[3]]!, 1))
        events.append((r[2], slabOf[r[1]]!, slabOf[r[3]]!, -1))
    }
    events.sort { $0.x < $1.x }
    var tree = CoverTree(ys: ys)
    var area = 0
    var previousX = events[0].x
    for event in events {
        area += tree.coveredLength * (event.x - previousX)
        previousX = event.x
        tree.update(event.from, event.to, event.change)
    }
    return area
}

/// Checks every unit square of a small grid: slow, but obviously right
func gridCount(_ rectangles: [[Int]], size: Int) -> Int {
    var count = 0
    for x in 0..<size {
        for y in 0..<size where rectangles.contains(where: { $0[0] <= x && x < $0[2] && $0[1] <= y && y < $0[3] }) {
            count += 1
        }
    }
    return count
}

print(coveredArea([[0, 0, 4, 3], [2, 1, 6, 5], [5, 0, 8, 2]]))
print(coveredArea([[0, 0, 1_000_000_000, 1_000_000_000], [5, 5, 10, 10]]))

// 200 random floors of up to 8 rectangles, compared with the grid count
var seed: UInt64 = 2024
func nextRandom(_ bound: Int) -> Int {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Int(seed >> 33) % bound
}
var agree = 0
for _ in 0..<200 {
    let rectangles = (0..<nextRandom(9)).map { _ -> [Int] in
        let (a, b, c, d) = (nextRandom(13), nextRandom(13), nextRandom(13), nextRandom(13))
        return [min(a, b), min(c, d), max(a, b), max(c, d)]
    }
    if coveredArea(rectangles) == gridCount(rectangles, size: 13) {
        agree += 1
    }
}
print("agree on \(agree) of 200 random floors")
