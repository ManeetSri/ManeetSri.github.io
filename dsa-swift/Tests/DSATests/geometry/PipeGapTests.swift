import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same pipes
private struct PipeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PipeGapTests {
    /// True when `actual` is within `tolerance` of `expected`, measured relative to the size of
    /// `expected` once that is bigger than 1.
    private func isClose(_ actual: Double, _ expected: Double, tolerance: Double = 1e-9) -> Bool {
        abs(actual - expected) <= tolerance * max(1, abs(expected))
    }

    /// A different, partly numerical method. The distance from a point to a segment comes from clamping
    /// the point's projection, as Doubles. The distance from a point moving along the first pipe to the
    /// second pipe is a convex function of its position, so ternary search finds its minimum, here to
    /// about 10⁻¹².
    private func reference(_ first: [[Int]], _ second: [[Int]]) -> Double {
        let (cx, cy) = (Double(second[0][0]), Double(second[0][1]))
        let (sx, sy) = (Double(second[1][0]) - cx, Double(second[1][1]) - cy)
        func toSecond(_ px: Double, _ py: Double) -> Double {
            let lengthSquared = sx * sx + sy * sy
            let u = lengthSquared == 0 ? 0 : min(1, max(0, ((px - cx) * sx + (py - cy) * sy) / lengthSquared))
            let (qx, qy) = (cx + u * sx, cy + u * sy)
            return ((px - qx) * (px - qx) + (py - qy) * (py - qy)).squareRoot()
        }
        let (ax, ay) = (Double(first[0][0]), Double(first[0][1]))
        let (rx, ry) = (Double(first[1][0]) - ax, Double(first[1][1]) - ay)
        func f(_ t: Double) -> Double { toSecond(ax + t * rx, ay + t * ry) }
        var (low, high) = (0.0, 1.0)
        for _ in 0..<100 {
            let m1 = low + (high - low) / 3, m2 = high - (high - low) / 3
            if f(m1) < f(m2) { high = m2 } else { low = m1 }
        }
        return min(f((low + high) / 2), f(0), f(1))
    }

    @Test("Examples", arguments: [
        ([[0, 0], [4, 4]], [[0, 4], [4, 0]], 0.0),                 // crossing
        ([[0, 0], [4, 0]], [[4, 0], [6, 3]], 0.0),                 // a shared end
        ([[0, 0], [4, 0]], [[1, 1], [5, 1]], 1.0),                 // parallel
        ([[0, 0], [4, 0]], [[2, 1], [2, 5]], 1.0),                 // a T that doesn't quite touch
        ([[0, 0], [1, 1]], [[4, 5], [7, 9]], 5.0),                 // end to end
        ([[0, 0], [2, 0]], [[5, 0], [9, 0]], 3.0),                 // collinear with a gap
        ([[0, 0], [0, 0]], [[3, 4], [3, 4]], 5.0),                 // two single points
        ([[0, 0], [0, 0]], [[-5, 1], [5, 1]], 1.0),                // a point above a pipe
        ([[0, 0], [4, 4]], [[4, 0], [6, -2]], 2.8284271247461903), // 2√2, from (4, 0) to (2, 2)
    ] as [([[Int]], [[Int]], Double)])
    func examples(first: [[Int]], second: [[Int]], expected: Double) {
        #expect(isClose(PipeGap.shortestGap(first, second), expected))
        #expect(isClose(PipeGap.shortestGap(second, first), expected))
        #expect(isClose(PipeGap.shortestGap([first[1], first[0]], [second[1], second[0]]), expected))
    }

    @Test("Touching is exactly zero, and a near miss is not")
    func nearMiss() {
        let m = 1_000_000
        // The point is 1 / √(8 × 10¹² - 4 × 10⁶ + 1), about 3.5 × 10⁻⁷, from the long pipe
        let expected = 1.0 / Double(8_000_000_000_000 - 4_000_000 + 1).squareRoot()
        let gap = PipeGap.shortestGap([[-m, -m], [m, m - 1]], [[-m + 1, -m + 1], [-m + 1, -m + 1]])
        #expect(gap > 0)
        #expect(isClose(gap, expected))
        #expect(PipeGap.shortestGap([[-m, -m], [m, m]], [[-m + 1, -m + 1], [-m + 1, -m + 1]]) == 0)
        #expect(PipeGap.shortestGap([[-m, -m], [m, m - 1]], [[-m, m], [m, -m]]) == 0)
        #expect(isClose(PipeGap.shortestGap([[-m, -m], [-m, -m]], [[m, m], [m, m]]), 2_000_000 * 2.0.squareRoot()))
    }

    @Test("Matches a numerical search on 2,000 random pairs of pipes")
    func randomSmall() {
        var random = PipeRandom(seed: 65)
        for _ in 0..<2_000 {
            let range = Int.random(in: 1...10, using: &random)
            let first = (0..<2).map { _ in [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)] }
            let second = (0..<2).map { _ in [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)] }
            #expect(isClose(PipeGap.shortestGap(first, second), reference(first, second), tolerance: 1e-8))
        }
    }
}
