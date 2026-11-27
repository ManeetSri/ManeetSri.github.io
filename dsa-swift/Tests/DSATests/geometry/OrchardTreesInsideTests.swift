import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same fences
private struct OrchardRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// A random simple polygon. Points around the origin, at least one in each open quadrant and no two in
/// the same direction, joined in angle order: every edge stays inside its own wedge of less than 180°,
/// so no two edges cross. Then the polygon is shifted, started at a random corner and maybe reversed.
private func orchardStarPolygon(range: Int, extra: Int, using random: inout OrchardRandom) -> [[Int]] {
    var points: [[Int]] = [[1, 1], [-1, 1], [-1, -1], [1, -1]].map {
        [$0[0] * Int.random(in: 1...range, using: &random), $0[1] * Int.random(in: 1...range, using: &random)]
    }
    for _ in 0..<extra {
        points.append([Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)])
    }
    func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }
    var directions = Set<[Int]>()
    points = points.filter { point in
        guard point != [0, 0] else { return false }
        let g = gcd(abs(point[0]), abs(point[1]))
        return directions.insert([point[0] / g, point[1] / g]).inserted
    }
    func half(_ p: [Int]) -> Int { p[1] > 0 || (p[1] == 0 && p[0] > 0) ? 0 : 1 }
    points.sort { a, b in
        half(a) != half(b) ? half(a) < half(b) : a[0] * b[1] - a[1] * b[0] > 0
    }
    let (dx, dy) = (Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random))
    let start = Int.random(in: 0..<points.count, using: &random)
    var polygon = (0..<points.count).map { points[($0 + start) % points.count] }.map { [$0[0] + dx, $0[1] + dy] }
    if Bool.random(using: &random) {
        polygon.reverse()
    }
    return polygon
}

@Suite struct OrchardTreesInsideTests {
    /// 1 inside, 0 on the fence, -1 outside: an on-segment check for every edge, then the winding
    /// number, found by counting quarter turns as the edges go round the point.
    private func place(_ polygon: [[Int]], _ point: [Int]) -> Int {
        let n = polygon.count
        for i in 0..<n {
            let a = polygon[i], b = polygon[(i + 1) % n]
            let cross = (b[0] - a[0]) * (point[1] - a[1]) - (b[1] - a[1]) * (point[0] - a[0])
            if cross == 0 && (point[0] - a[0]) * (point[0] - b[0]) <= 0 && (point[1] - a[1]) * (point[1] - b[1]) <= 0 {
                return 0
            }
        }
        func quadrant(_ x: Int, _ y: Int) -> Int {
            if x > 0 && y >= 0 { return 0 }
            if x <= 0 && y > 0 { return 1 }
            if x < 0 && y <= 0 { return 2 }
            return 3
        }
        var quarterTurns = 0
        for i in 0..<n {
            let (ax, ay) = (polygon[i][0] - point[0], polygon[i][1] - point[1])
            let (bx, by) = (polygon[(i + 1) % n][0] - point[0], polygon[(i + 1) % n][1] - point[1])
            switch (quadrant(bx, by) - quadrant(ax, ay) + 4) % 4 {
            case 1: quarterTurns += 1
            case 3: quarterTurns -= 1
            case 2: quarterTurns += ax * by - ay * bx > 0 ? 2 : -2
            default: break
            }
        }
        return quarterTurns != 0 ? 1 : -1
    }

    /// Counts by checking every grid point in the bounding box. Small fences only.
    private func bruteForce(_ fence: [[Int]]) -> Int {
        let xs = fence.map { $0[0] }, ys = fence.map { $0[1] }
        var count = 0
        for x in xs.min()!...xs.max()! {
            for y in ys.min()!...ys.max()! where place(fence, [x, y]) == 1 {
                count += 1
            }
        }
        return count
    }

    @Test("Examples", arguments: [
        ([[0, 0], [4, 0], [4, 4], [0, 4]], 9),
        ([[0, 0], [4, 0], [0, 4]], 3),
        ([[0, 0], [5, 0], [0, 1]], 0),
        ([[0, 0], [6, 0], [6, 2], [2, 2], [2, 6], [0, 6]], 9),
        ([[0, 0], [2, 0], [4, 0], [4, 3], [0, 3]], 6),
        ([[1, 1], [3, 5], [7, 2]], 10),
        ([[0, 0], [2, -2], [4, 0], [2, 2]], 5),
    ] as [([[Int]], Int)])
    func examples(fence: [[Int]], expected: Int) {
        #expect(OrchardTreesInside.treesInside(fence) == expected)
        #expect(OrchardTreesInside.treesInside(fence.reversed()) == expected)
    }

    @Test("Matches a grid scan on 400 random fences, concave ones included")
    func randomSmall() {
        var random = OrchardRandom(seed: 65)
        for round in 0..<400 {
            let fence = orchardStarPolygon(range: round < 200 ? 4 : 9, extra: Int.random(in: 0...10, using: &random), using: &random)
            #expect(OrchardTreesInside.treesInside(fence) == bruteForce(fence))
        }
    }

    @Test("Big fields: too many trees to count one by one")
    func bigFields() {
        let million = 1_000_000
        #expect(OrchardTreesInside.treesInside([[0, 0], [million, 0], [0, million]]) == 499_998_500_001)
        #expect(OrchardTreesInside.treesInside([[0, -million], [million, 0], [0, million], [-million, 0]]) == 1_999_998_000_001)
        #expect(OrchardTreesInside.treesInside([[-million, -million], [million, -million], [million, million], [-million, million]])
            == (2 * million - 1) * (2 * million - 1))
    }

    @Test("A skyline-shaped fence with 100,000 corners")
    func skyline() {
        // Columns 0..<width, each one unit wide, of heights that change at every step. On the line
        // x = k between two columns, the trees strictly inside are at heights 1 up to the shorter
        // column's height minus 1.
        var random = OrchardRandom(seed: 2_065)
        let width = 49_999
        var heights = [Int.random(in: 1...1_000_000, using: &random)]
        while heights.count < width {
            let next = Int.random(in: 1...1_000_000, using: &random)
            if next != heights.last! {
                heights.append(next)
            }
        }
        var fence = [[0, 0], [width, 0]]
        for x in stride(from: width, through: 1, by: -1) {
            fence.append([x, heights[x - 1]])
            fence.append([x - 1, heights[x - 1]])
        }
        let expected = (1..<width).reduce(0) { $0 + min(heights[$1 - 1], heights[$1]) - 1 }
        #expect(fence.count == 100_000)
        #expect(OrchardTreesInside.treesInside(fence) == expected)
    }
}
