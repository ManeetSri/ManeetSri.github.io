import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct GapRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct KthSmallestHouseGapTests {
    /// Every distance, sorted
    private func allGaps(_ houses: [Int]) -> [Int] {
        var gaps: [Int] = []
        for i in houses.indices {
            for j in (i + 1)..<max(i + 1, houses.count) {
                gaps.append(abs(houses[i] - houses[j]))
            }
        }
        return gaps.sorted()
    }

    @Test("The examples", arguments: [
        ([1, 3, 1], 1, 0),
        ([1, 6, 1], 3, 5),
        ([1, 3, 7, 10], 4, 6),
        ([5, 5, 5], 3, 0),
        ([10, 1], 1, 9),
    ])
    func examples(houses: [Int], k: Int, expected: Int) {
        #expect(KthSmallestHouseGap.kthGap(houses, k: k) == expected)
    }

    @Test("Every k on small streets matches sorting all the distances", arguments: [1, 2, 3])
    func everyK(seed: UInt64) {
        var random = GapRandom(seed: seed)
        for trial in 0..<40 {
            let n = Int.random(in: 2...14, using: &random)
            let top = trial.isMultiple(of: 3) ? 5 : 1_000_000_000
            let houses = (0..<n).map { _ in Int.random(in: 0...top, using: &random) }
            let gaps = allGaps(houses)
            for k in 1...gaps.count where KthSmallestHouseGap.kthGap(houses, k: k) != gaps[k - 1] {
                Issue.record("houses \(houses): k = \(k) should give \(gaps[k - 1])")
                return
            }
        }
    }

    @Test("The smallest and the largest distance")
    func extremes() {
        let houses = [0, 1_000_000_000, 500, 499]
        #expect(KthSmallestHouseGap.kthGap(houses, k: 1) == 1)
        #expect(KthSmallestHouseGap.kthGap(houses, k: 6) == 1_000_000_000)
    }

    @Test("100,000 houses")
    func large() {
        let n = 100_000
        // Evenly spaced houses 0, 10, 20, …: there are n − g pairs at distance 10g
        let even = (0..<n).map { $0 * 10 }
        #expect(KthSmallestHouseGap.kthGap(even, k: 1) == 10)
        #expect(KthSmallestHouseGap.kthGap(even, k: n - 1) == 10)
        #expect(KthSmallestHouseGap.kthGap(even, k: n) == 20)
        #expect(KthSmallestHouseGap.kthGap(even, k: n * (n - 1) / 2) == 10 * (n - 1))
        // n − 1 + n − 2 pairs are within 20, so the next one is at 30
        #expect(KthSmallestHouseGap.kthGap(even, k: 2 * n - 2) == 30)
        // Random houses: check the answer by counting pairs on both sides of it
        var random = GapRandom(seed: 59)
        let houses = (0..<n).map { _ in Int.random(in: 0...1_000_000_000, using: &random) }
        let k = 1_234_567_890
        let answer = KthSmallestHouseGap.kthGap(houses, k: k)
        let sorted = houses.sorted()
        func within(_ d: Int) -> Int {
            var count = 0
            var left = 0
            for right in sorted.indices {
                while sorted[right] - sorted[left] > d { left += 1 }
                count += right - left
            }
            return count
        }
        #expect(answer > 0)
        if answer > 0 {
            #expect(within(answer) >= k, "fewer than k pairs are within the answer")
            #expect(within(answer - 1) < k, "a smaller distance already has k pairs within it")
        }
    }
}
