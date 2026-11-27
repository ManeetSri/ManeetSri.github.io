import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SlopeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SkiSlopeDescentTests {
    /// Try every run from every top cell: up to 3^(rows - 1) each
    private func everyRun(_ slope: [[Int]]) -> Int {
        let cols = slope[0].count
        func ski(_ r: Int, _ c: Int) -> Int {
            if r == slope.count - 1 { return slope[r][c] }
            var best = Int.max
            for next in max(0, c - 1)...min(cols - 1, c + 1) {
                best = min(best, ski(r + 1, next))
            }
            return slope[r][c] + best
        }
        return (0..<cols).map { ski(0, $0) }.min()!
    }

    /// A different method: the cheapest way from each cell down to the bottom, filled upwards
    private func fromTheBottom(_ slope: [[Int]]) -> Int {
        let cols = slope[0].count
        var below = slope[slope.count - 1]
        for r in stride(from: slope.count - 2, through: 0, by: -1) {
            below = (0..<cols).map { c in slope[r][c] + below[max(0, c - 1)...min(cols - 1, c + 1)].min()! }
        }
        return below.min()!
    }

    @Test("Examples and small slopes", arguments: [
        ([[4, 1, 6, 3], [2, 8, 5, 7], [9, 3, 1, 4], [6, 2, 7, 5]], 8),
        ([[5, -1, 4], [2, 9, -3], [6, -2, 8]], -6),
        ([[7]], 7),
        ([[3, -2, 5]], -2),
        ([[1], [2], [3]], 6),
        ([[1, 100], [100, 1]], 2),
        ([[1, 100, 100], [100, 100, 1]], 101),
        ([[0, 0, 9], [9, 9, 0], [9, 0, 9]], 0),
    ] as [([[Int]], Int)])
    func examples(slope: [[Int]], expected: Int) {
        #expect(SkiSlopeDescent.cheapestRun(slope) == expected)
    }

    @Test("Matches trying every run on 300 small random slopes")
    func randomSmall() {
        var random = SlopeRandom(seed: 9)
        for _ in 0..<300 {
            let rows = Int.random(in: 1...7, using: &random)
            let cols = Int.random(in: 1...6, using: &random)
            let slope = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: -30...30, using: &random) } }
            #expect(SkiSlopeDescent.cheapestRun(slope) == everyRun(slope))
        }
    }

    @Test("500 × 500 with a planted run of zeros among positive efforts")
    func plantedRun() {
        var random = SlopeRandom(seed: 500)
        var slope = (0..<500).map { _ in (0..<500).map { _ in Int.random(in: 1...1_000, using: &random) } }
        var column = Int.random(in: 0..<500, using: &random)
        for r in 0..<500 {
            slope[r][column] = 0
            column = min(499, max(0, column + Int.random(in: -1...1, using: &random)))
        }
        #expect(SkiSlopeDescent.cheapestRun(slope) == 0)
    }

    @Test("Large random slopes, including tall, wide and negative ones")
    func largeRandom() {
        var random = SlopeRandom(seed: 31)
        for (rows, cols) in [(500, 500), (1, 500), (500, 1), (300, 2)] {
            let slope = (0..<rows).map { _ in (0..<cols).map { _ in Int.random(in: -1_000...1_000, using: &random) } }
            #expect(SkiSlopeDescent.cheapestRun(slope) == fromTheBottom(slope))
        }
    }
}
