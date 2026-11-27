import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same motorways
private struct CoverageRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RepeaterCoverageTests {
    /// Checks every metre of a short road: slow, but clearly right.
    private func reference(_ repeaters: [[Int]], _ k: Int) -> Int {
        let length = repeaters.map { $0[1] }.max() ?? 0
        var cover = [Int](repeating: 0, count: length + 1)
        for repeater in repeaters {
            for position in repeater[0]..<repeater[1] {
                cover[position] += 1
            }
        }
        var running = 0
        var longest = 0
        for position in 0..<length {
            running = cover[position] >= k ? running + 1 : 0
            longest = max(longest, running)
        }
        return longest
    }

    @Test("Examples", arguments: [
        ([[10, 50], [30, 1_000_000], [40, 60], [999_990, 2_000_000_000]], 2, 30),
        ([[10, 50], [30, 1_000_000], [40, 60], [999_990, 2_000_000_000]], 1, 1_999_999_990),
        ([[10, 50], [30, 1_000_000], [40, 60], [999_990, 2_000_000_000]], 3, 10),
        ([[0, 10], [10, 20], [25, 30]], 1, 20),
        ([[0, 5], [3, 8]], 3, 0),
        ([], 1, 0),
        ([[5, 6]], 1, 1),
        ([[0, 2_000_000_000], [0, 2_000_000_000]], 2, 2_000_000_000),
        ([[0, 10], [0, 10], [5, 20], [10, 20]], 2, 20),
    ] as [([[Int]], Int, Int)])
    func examples(repeaters: [[Int]], k: Int, expected: Int) {
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: k) == expected)
    }

    @Test("Random short roads match checking every metre")
    func randomSmall() {
        var random = CoverageRandom(seed: 62)
        for _ in 0..<400 {
            let road = Int.random(in: 1...40, using: &random)
            let repeaters = (0..<Int.random(in: 0...10, using: &random)).map { _ -> [Int] in
                let start = Int.random(in: 0..<road, using: &random)
                return [start, Int.random(in: (start + 1)...road, using: &random)]
            }
            let k = Int.random(in: 1...4, using: &random)
            let expected = reference(repeaters, k)
            let actual = RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: k)
            if actual != expected {
                Issue.record("repeaters \(repeaters), k = \(k): expected \(expected), got \(actual)")
                return
            }
        }
    }

    @Test("50,000 repeaters over two billion metres, with a planted answer")
    func large() {
        // Background: 48,000 short repeaters scattered over the road, none overlapping another
        // (each sits alone in its own 40,000-metre slot), so the background never reaches k = 2.
        // Then plant a chain of overlapping pairs whose reliable pieces join into one stretch.
        var random = CoverageRandom(seed: 2_026)
        var repeaters: [[Int]] = []
        for slot in 0..<48_000 {
            let base = slot * 40_000
            let start = base + Int.random(in: 0..<10_000, using: &random)
            repeaters.append([start, start + Int.random(in: 1...9_000, using: &random)])
        }
        // The planted stretch starts at 1,980,000,000 + 100 and ends 900,000 metres later: pairs of
        // repeaters that each overlap on exactly 900 metres, touching end to end.
        let plantedStart = 1_980_000_100
        for piece in 0..<1_000 {
            let start = plantedStart + piece * 900
            repeaters.append([start - Int.random(in: 0...50, using: &random), start + 900])
            repeaters.append([start, start + 900 + Int.random(in: 0...50, using: &random)])
        }
        repeaters.shuffle(using: &random)
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: 2) == 900_000)
        // Neighbouring pairs overlap a little at their joins, but never by more than 100 metres
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: 3) <= 100)
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: 4) == 0)
    }

    @Test("Many repeaters covering the whole road")
    func nested() {
        let n = 50_000
        let repeaters = (0..<n).map { [$0 * 10, 2_000_000_000 - $0 * 10] }
        // The point x is covered by every repeater with i * 10 ≤ x < 2e9 − i * 10, so the stretch
        // covered by at least k is [ (k − 1) * 10, 2e9 − (k − 1) * 10 ).
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: 1) == 2_000_000_000)
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: 1_000) == 2_000_000_000 - 2 * 999 * 10)
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: n) == 2_000_000_000 - 2 * (n - 1) * 10)
        #expect(RepeaterCoverage.longestReliableStretch(repeaters: repeaters, atLeast: n + 1) == 0)
    }
}
