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

func squaredDistance(_ a: Point, _ b: Point) -> Int {
    (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)   // no square root needed to compare
}

final class KDNode {
    let point: Point
    let index: Int
    let splitsOnX: Bool                         // true: left has smaller x; false: smaller y
    var left: KDNode?
    var right: KDNode?

    init(point: Point, index: Int, splitsOnX: Bool) {
        self.point = point
        self.index = index
        self.splitsOnX = splitsOnX
    }
}

// Split at the median, alternating between x and y, so the tree is balanced
func build(_ items: [(point: Point, index: Int)], depth: Int = 0) -> KDNode? {
    guard !items.isEmpty else { return nil }
    let onX = depth % 2 == 0
    let sorted = items.sorted { onX ? $0.point.x < $1.point.x : $0.point.y < $1.point.y }
    let middle = sorted.count / 2
    let node = KDNode(point: sorted[middle].point, index: sorted[middle].index, splitsOnX: onX)
    node.left = build(Array(sorted[..<middle]), depth: depth + 1)
    node.right = build(Array(sorted[(middle + 1)...]), depth: depth + 1)
    return node
}

var checked = 0                                 // distances computed, to measure the pruning

func nearest(to query: Point, in node: KDNode?, best: inout (index: Int, distance: Int)) {
    guard let node else { return }
    checked += 1
    let distance = squaredDistance(node.point, query)
    if distance < best.distance { best = (node.index, distance) }
    let gap = node.splitsOnX ? query.x - node.point.x : query.y - node.point.y
    let (near, far) = gap < 0 ? (node.left, node.right) : (node.right, node.left)
    nearest(to: query, in: near, best: &best)           // the side the query is on, first
    if gap * gap < best.distance {                      // could the other side hold anything closer?
        nearest(to: query, in: far, best: &best)
    }
}

var generator = SeededGenerator(state: 5)
let pins = (0..<2_000).map { _ in Point(x: Int(generator.next() % 10_000), y: Int(generator.next() % 10_000)) }
let root = build(pins.enumerated().map { ($0.element, $0.offset) })

func bruteForce(_ query: Point) -> Int {
    pins.indices.min { squaredDistance(pins[$0], query) < squaredDistance(pins[$1], query) }!
}

for query in [Point(x: 5_000, y: 5_000), Point(x: 0, y: 0), Point(x: 9_999, y: 123)] {
    var best = (index: -1, distance: Int.max)
    checked = 0
    nearest(to: query, in: root, best: &best)
    print("(\(query.x), \(query.y)) → pin \(best.index), distance² \(best.distance),",
          "\(checked) distances, brute force agrees: \(best.index == bruteForce(query))")
}

checked = 0
for _ in 0..<1_000 {
    let query = Point(x: Int(generator.next() % 10_000), y: Int(generator.next() % 10_000))
    var best = (index: -1, distance: Int.max)
    nearest(to: query, in: root, best: &best)
}
print("average distances per query:", checked / 1_000, "of", pins.count)
