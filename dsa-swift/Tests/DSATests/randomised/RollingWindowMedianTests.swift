import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same readings
private struct MedianRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RollingWindowMedianTests {
    /// Sorts each window: slow, but clearly right.
    private func reference(_ readings: [Int], _ k: Int) -> [Double] {
        (0...(readings.count - k)).map { start in
            let window = readings[start..<(start + k)].sorted()
            return k % 2 == 1 ? Double(window[k / 2]) : (Double(window[k / 2 - 1]) + Double(window[k / 2])) / 2
        }
    }

    @Test("Examples", arguments: [
        ([5, 2, 8, 1, 9, 3], 3, [5.0, 2.0, 8.0, 3.0]),
        ([5, 2, 8, 1, 9, 3], 2, [3.5, 5.0, 4.5, 5.0, 6.0]),
        ([4, 4, 4, 4], 4, [4.0]),
        ([7, -3, 7], 1, [7.0, -3.0, 7.0]),
        ([2_147_483_647, 2_147_483_647], 2, [2_147_483_647.0]),
        ([-1_000_000_000, 1_000_000_000], 2, [0.0]),
        ([1, 2, 3, 4, 5, 6], 6, [3.5]),
    ] as [([Int], Int, [Double])])
    func examples(readings: [Int], k: Int, expected: [Double]) {
        #expect(RollingWindowMedian.medians(readings, window: k) == expected)
    }

    @Test("Random small streams with many repeated values match sorting each window")
    func randomSmall() {
        var random = MedianRandom(seed: 67)
        for _ in 0..<400 {
            let n = Int.random(in: 1...30, using: &random)
            let k = Int.random(in: 1...n, using: &random)
            let spread = Int.random(in: 1...6, using: &random)
            let readings = (0..<n).map { _ in Int.random(in: -spread...spread, using: &random) }
            let expected = reference(readings, k)
            let actual = RollingWindowMedian.medians(readings, window: k)
            if actual != expected {
                Issue.record("readings \(readings), k = \(k): expected \(expected), got \(actual)")
                return
            }
        }
    }

    @Test("A rising then falling stream, which keeps moving values between the halves")
    func zigzag() {
        let readings = Array(0..<200) + Array((0..<200).reversed()) + Array(0..<200)
        for k in [1, 2, 7, 50, 199, 200, 201] {
            #expect(RollingWindowMedian.medians(readings, window: k) == reference(readings, k), "k = \(k)")
        }
    }

    @Test("60,000 readings with windows of 30,000")
    func large() {
        var random = MedianRandom(seed: 2_026)
        let n = 60_000
        let k = 30_000
        let readings = (0..<n).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let medians = RollingWindowMedian.medians(readings, window: k)
        #expect(medians.count == n - k + 1)
        guard medians.count == n - k + 1 else { return }
        for start in [0, 777, n - k] {
            let window = readings[start..<(start + k)].sorted()
            #expect(medians[start] == (Double(window[k / 2 - 1]) + Double(window[k / 2])) / 2, "window starting at \(start)")
        }
    }

    @Test("A long increasing stream: each window's median is its middle")
    func increasing() {
        let n = 60_000
        let k = 20_001
        let readings = Array(0..<n).map { $0 * 2 }
        let expected = (0...(n - k)).map { Double(($0 + k / 2) * 2) }
        #expect(RollingWindowMedian.medians(readings, window: k) == expected)
    }
}
