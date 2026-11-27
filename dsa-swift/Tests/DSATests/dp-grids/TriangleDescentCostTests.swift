import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TriangleRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TriangleDescentCostTests {
    /// Try every one of the 2^(rows - 1) paths
    private func everyPath(_ triangle: [[Int]]) -> Int {
        func walk(_ r: Int, _ i: Int) -> Int {
            if r == triangle.count - 1 { return triangle[r][i] }
            return triangle[r][i] + min(walk(r + 1, i), walk(r + 1, i + 1))
        }
        return walk(0, 0)
    }

    /// A different method: fill top-down, then take the minimum of the last row
    private func topDown(_ triangle: [[Int]]) -> Int {
        var cost = [triangle[0][0]]
        for r in 1..<triangle.count {
            cost = (0...r).map { i in
                triangle[r][i] + min(i > 0 ? cost[i - 1] : Int.max, i < r ? cost[i] : Int.max)
            }
        }
        return cost.min()!
    }

    private func randomTriangle(rows: Int, values: ClosedRange<Int>, using random: inout TriangleRandom) -> [[Int]] {
        (0..<rows).map { r in (0...r).map { _ in Int.random(in: values, using: &random) } }
    }

    @Test("Examples and small triangles", arguments: [
        ([[5], [4, 7], [9, 8, 1], [2, 6, 3, 4]], 16),
        ([[-3]], -3),
        ([[1], [2, 3]], 3),
        ([[2], [-1, 5], [4, -6, 1]], -5),
        ([[0], [0, 0], [0, 0, 0]], 0),
        ([[1], [9, 1], [9, 9, 1], [9, 9, 9, 1]], 4),
        ([[1], [1, 9], [1, 9, 9], [1, 9, 9, 9]], 4),
        ([[10], [-10, 3], [5, 5, -20]], -7),
    ] as [([[Int]], Int)])
    func examples(triangle: [[Int]], expected: Int) {
        #expect(TriangleDescentCost.cheapest(triangle) == expected)
    }

    @Test("Matches trying every path on 300 small random triangles")
    func randomSmall() {
        var random = TriangleRandom(seed: 3)
        for _ in 0..<300 {
            let triangle = randomTriangle(rows: Int.random(in: 1...12, using: &random), values: -20...20, using: &random)
            #expect(TriangleDescentCost.cheapest(triangle) == everyPath(triangle))
        }
    }

    @Test("1,000 rows: a planted path of zeros among positive numbers")
    func plantedPath() {
        // 2^999 paths: only a DP can do this
        var random = TriangleRandom(seed: 1_000)
        var triangle = randomTriangle(rows: 1_000, values: 1...10_000, using: &random)
        var position = 0
        for r in triangle.indices {
            triangle[r][position] = 0
            if Bool.random(using: &random) {
                position += 1
            }
        }
        #expect(TriangleDescentCost.cheapest(triangle) == 0)
    }

    @Test("1,000 rows of random values, positive and negative")
    func largeRandom() {
        var random = TriangleRandom(seed: 77)
        let triangle = randomTriangle(rows: 1_000, values: -10_000...10_000, using: &random)
        #expect(TriangleDescentCost.cheapest(triangle) == topDown(triangle))

        let flat = (0..<1_000).map { Array(repeating: 7, count: $0 + 1) }
        #expect(TriangleDescentCost.cheapest(flat) == 7_000)
    }
}
