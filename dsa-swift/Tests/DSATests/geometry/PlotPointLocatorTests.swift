import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same plots
private struct PlotRandom: RandomNumberGenerator {
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
private func plotStarPolygon(range: Int, extra: Int, using random: inout PlotRandom) -> [[Int]] {
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

@Suite struct PlotPointLocatorTests {
    /// A different method: an on-segment check for every edge, then the winding number, found by
    /// counting quarter turns as the edges go round the point.
    private func reference(_ polygon: [[Int]], _ point: [Int]) -> Int {
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

    // A U-shaped plot: two arms of height 5 with a notch between x = 2 and x = 4, above y = 2
    private let uShape = [[0, 0], [6, 0], [6, 5], [4, 5], [4, 2], [2, 2], [2, 5], [0, 5]]

    @Test("The U-shaped example")
    func uShaped() {
        let queries = [[1, 1], [3, 3], [3, 2], [5, 4], [3, 1], [7, 1], [0, 3], [6, 5], [1, 5], [3, 5], [-1, 2], [5, 2], [-1, 5]]
        let expected = [1, -1, 0, 1, 1, -1, 0, 0, 0, -1, -1, 1, -1]
        #expect(PlotPointLocator.locate(uShape, queries) == expected)
        #expect(PlotPointLocator.locate(uShape.reversed(), queries) == expected)
    }

    @Test("Rays that run through corners and along edges")
    func awkwardRays() {
        // A diamond: rays to the right from points level with the side corners pass straight through one
        let diamond = [[0, -2], [2, 0], [0, 2], [-2, 0]]
        #expect(PlotPointLocator.locate(diamond, [[-3, 0], [-1, 0], [0, 0], [2, 0], [3, 0], [0, 2], [0, 3], [1, 1]]) == [-1, 1, 1, 0, -1, 0, -1, 0])
        // A zigzag top edge: rays at y = 1 pass through both valleys, and rays at y = 3 touch the peaks
        let zigzag = [[0, 0], [8, 0], [8, 3], [6, 1], [4, 3], [2, 1], [0, 3]]
        let zigzagQueries = [[-1, 3], [1, 1], [3, 1], [4, 2], [5, 1], [7, 1], [2, 1], [3, 3], [5, 3], [4, 3], [-1, 1], [9, 1], [1, 2]]
        #expect(PlotPointLocator.locate(zigzag, zigzagQueries) == [-1, 1, 1, 1, 1, 1, 0, -1, -1, 0, -1, -1, 0])
        #expect(PlotPointLocator.locate([[0, 0], [1, 0], [0, 1]], []) == [])
    }

    @Test("Matches the winding number on 300 random plots, at every grid point around them")
    func randomSmall() {
        var random = PlotRandom(seed: 4)
        for round in 0..<300 {
            let plot = plotStarPolygon(range: round < 150 ? 3 : 7, extra: Int.random(in: 0...12, using: &random), using: &random)
            let xs = plot.map { $0[0] }, ys = plot.map { $0[1] }
            var queries: [[Int]] = []
            for x in (xs.min()! - 1)...(xs.max()! + 1) {
                for y in (ys.min()! - 1)...(ys.max()! + 1) {
                    queries.append([x, y])
                }
            }
            #expect(PlotPointLocator.locate(plot, queries) == queries.map { reference(plot, $0) })
        }
    }

    @Test("Exact at a billion: points a hair inside or outside a long edge")
    func hugeCoordinates() {
        let big = 1_000_000_000
        // The edge from (-big, -big) to (big, big - 1) passes through no other grid point. These two
        // queries are about 3.5 × 10⁻¹⁰ from it, one on each side: far too close for Double to tell.
        let triangle = [[-big, -big], [big, big - 1], [-big, big]]
        let queries = [[-big + 1, -big + 1], [big - 1, big - 2], [-big, -big], [0, big], [-big, 0], [0, 0], [big, big]]
        #expect(PlotPointLocator.locate(triangle, queries) == [1, -1, 0, -1, 0, 1, -1])
    }

    @Test("A plot with about 1,000 corners and 1,200 queries")
    func large() {
        var random = PlotRandom(seed: 1_000)
        let plot = plotStarPolygon(range: 1_000_000, extra: 996, using: &random)
        let queries = (0..<1_000).map { _ in
            [Int.random(in: -2_000_000...2_000_000, using: &random), Int.random(in: -2_000_000...2_000_000, using: &random)]
        } + plot.prefix(100) + plot.prefix(100).map { [$0[0] + 1, $0[1]] }
        #expect(PlotPointLocator.locate(plot, queries) == queries.map { reference(plot, $0) })
    }
}
