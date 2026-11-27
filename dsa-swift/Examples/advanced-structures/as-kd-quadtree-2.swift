// Generated from src/dsa/content/lessons/advanced-structures/as-kd-quadtree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

struct Point {
    let x: Int
    let y: Int
}

// A half-open rectangle: minX ≤ x < maxX and minY ≤ y < maxY
struct Rect {
    let minX: Int, minY: Int, maxX: Int, maxY: Int

    func contains(_ p: Point) -> Bool {
        minX <= p.x && p.x < maxX && minY <= p.y && p.y < maxY
    }

    func contains(_ other: Rect) -> Bool {
        minX <= other.minX && other.maxX <= maxX && minY <= other.minY && other.maxY <= maxY
    }

    func intersects(_ other: Rect) -> Bool {
        minX < other.maxX && other.minX < maxX && minY < other.maxY && other.minY < maxY
    }
}

final class QuadTree {
    let bounds: Rect
    let capacity = 4
    private(set) var count = 0                  // points anywhere in this region
    private var points: [Point] = []            // only a leaf holds points
    private var children: [QuadTree] = []       // empty, or four quadrants

    init(_ bounds: Rect) {
        self.bounds = bounds
    }

    @discardableResult
    func insert(_ p: Point) -> Bool {
        guard bounds.contains(p) else { return false }
        count += 1
        if children.isEmpty {
            if points.count < capacity || bounds.maxX - bounds.minX <= 1 {
                points.append(p)                // room here, or too small to split
                return true
            }
            split()
        }
        return children.contains { $0.insert(p) }
    }

    private func split() {
        let midX = (bounds.minX + bounds.maxX) / 2
        let midY = (bounds.minY + bounds.maxY) / 2
        children = [
            QuadTree(Rect(minX: bounds.minX, minY: bounds.minY, maxX: midX, maxY: midY)),
            QuadTree(Rect(minX: midX, minY: bounds.minY, maxX: bounds.maxX, maxY: midY)),
            QuadTree(Rect(minX: bounds.minX, minY: midY, maxX: midX, maxY: bounds.maxY)),
            QuadTree(Rect(minX: midX, minY: midY, maxX: bounds.maxX, maxY: bounds.maxY)),
        ]
        for p in points {
            _ = children.contains { $0.insert(p) }
        }
        points = []
    }

    // How many points lie in area, and how many regions the search opened
    func count(in area: Rect, visited: inout Int) -> Int {
        guard bounds.intersects(area) else { return 0 }     // no overlap: skip the region
        visited += 1
        if area.contains(bounds) { return count }           // wholly inside: no need to look
        if children.isEmpty {
            return points.filter { area.contains($0) }.count
        }
        return children.reduce(0) { $0 + $1.count(in: area, visited: &visited) }
    }

    // One cluster per region at the given depth: its centre and how many points it holds
    func clusters(depth: Int) -> [(x: Int, y: Int, count: Int)] {
        if count == 0 { return [] }
        if depth == 0 || children.isEmpty {
            return [((bounds.minX + bounds.maxX) / 2, (bounds.minY + bounds.maxY) / 2, count)]
        }
        return children.flatMap { $0.clusters(depth: depth - 1) }
    }
}

// 3,000 map pins: two dense cities and some countryside, on a 1,024 × 1,024 map
var generator = SeededGenerator(state: 11)
let map = QuadTree(Rect(minX: 0, minY: 0, maxX: 1_024, maxY: 1_024))
for i in 0..<3_000 {
    let (cx, cy, spread) = i % 3 == 0 ? (512, 512, 1_024) : i % 3 == 1 ? (200, 260, 80) : (800, 700, 120)
    let x = cx + Int(generator.next() % UInt64(spread)) - spread / 2
    let y = cy + Int(generator.next() % UInt64(spread)) - spread / 2
    map.insert(Point(x: x, y: y))
}
print("pins on the map:", map.count)

var visited = 0
for screen in [Rect(minX: 150, minY: 200, maxX: 300, maxY: 330), Rect(minX: 0, minY: 900, maxX: 120, maxY: 1_024)] {
    visited = 0
    print("pins on screen:", map.count(in: screen, visited: &visited), "after opening", visited, "regions")
}

for depth in [1, 2] {
    let bubbles = map.clusters(depth: depth).filter { $0.count >= 100 }
    print("zoom depth \(depth): \(bubbles.map { "\($0.count) near (\($0.x), \($0.y))" })")
}
