import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SteadyRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LongestSteadyStretchTests {
    /// Every start, extended while the run stays steady
    private func brute(_ readings: [Int], _ tolerance: Int) -> Int {
        var best = 0
        for start in readings.indices {
            var high = readings[start]
            var low = readings[start]
            for end in start..<readings.count {
                high = max(high, readings[end])
                low = min(low, readings[end])
                if high - low > tolerance { break }
                best = max(best, end - start + 1)
            }
        }
        return best
    }

    @Test("The examples", arguments: [
        ([8, 2, 4, 7], 4, 2),
        ([10, 1, 2, 4, 7, 2], 5, 4),
        ([4, 2, 2, 2, 4, 4, 2, 2], 0, 3),
        ([5], 0, 1),
        ([], 3, 0),
    ])
    func examples(readings: [Int], tolerance: Int, expected: Int) {
        #expect(LongestSteadyStretch.longest(readings, tolerance: tolerance) == expected)
    }

    @Test("Everything steady, rising readings, and extreme values")
    func edges() {
        #expect(LongestSteadyStretch.longest([3, 3, 3, 3], tolerance: 0) == 4)
        #expect(LongestSteadyStretch.longest([1, 2, 3, 4, 5, 6], tolerance: 2) == 3)
        #expect(LongestSteadyStretch.longest([6, 5, 4, 3, 2, 1], tolerance: 2) == 3)
        #expect(LongestSteadyStretch.longest([-1_000_000_000, 1_000_000_000], tolerance: 2_000_000_000) == 2)
        #expect(LongestSteadyStretch.longest([-1_000_000_000, 1_000_000_000], tolerance: 1_999_999_999) == 1)
        #expect(LongestSteadyStretch.longest([1, 9, 1, 9, 1], tolerance: 100) == 5)
    }

    @Test("Random readings match checking every run", arguments: [1, 2, 3])
    func matchesBrute(seed: UInt64) {
        var random = SteadyRandom(seed: seed)
        for _ in 0..<300 {
            let n = Int.random(in: 0...40, using: &random)
            let spread = Int.random(in: 0...20, using: &random)
            let readings = (0..<n).map { _ in Int.random(in: -spread...spread, using: &random) }
            let tolerance = Int.random(in: 0...(2 * spread + 1), using: &random)
            let expected = brute(readings, tolerance)
            let actual = LongestSteadyStretch.longest(readings, tolerance: tolerance)
            #expect(actual == expected, "\(readings), tolerance \(tolerance)")
            if actual != expected { return }
        }
    }

    @Test("200,000 readings")
    func large() {
        // All equal: the whole log is steady
        #expect(LongestSteadyStretch.longest(Array(repeating: 21, count: 200_000), tolerance: 0) == 200_000)
        // A slow drift: steady runs are exactly tolerance + 1 long
        let drift = Array(0..<200_000)
        #expect(LongestSteadyStretch.longest(drift, tolerance: 999) == 1_000)
        // A random walk, checked against the brute force on a slice it can handle
        var random = SteadyRandom(seed: 59)
        var walk = [0]
        for _ in 1..<200_000 {
            walk.append(walk[walk.count - 1] + Int.random(in: -3...3, using: &random))
        }
        let slice = Array(walk.prefix(2_000))
        #expect(LongestSteadyStretch.longest(slice, tolerance: 10) == brute(slice, 10))
        let whole = LongestSteadyStretch.longest(walk, tolerance: 10)
        #expect(whole >= brute(slice, 10) && whole < 200_000)
    }
}
