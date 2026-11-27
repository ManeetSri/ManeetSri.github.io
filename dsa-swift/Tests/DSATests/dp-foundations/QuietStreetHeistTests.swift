import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct QuietStreetRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct QuietStreetHeistTests {
    /// Try every plan: rob house i or not. Exponential, but clearly right.
    private func everyPlan(_ houses: [Int], from i: Int = 0) -> Int {
        if i >= houses.count {
            return 0
        }
        return max(everyPlan(houses, from: i + 1), houses[i] + everyPlan(houses, from: i + 2))
    }

    /// Two states per house: the best so far if this house is robbed, and if it isn't
    private func robbedOrNot(_ houses: [Int]) -> Int {
        var (robbed, notRobbed) = (0, 0)
        for cash in houses {
            (robbed, notRobbed) = (notRobbed + cash, max(robbed, notRobbed))
        }
        return max(robbed, notRobbed)
    }

    @Test("Examples and small cases", arguments: [
        ([3, 10, 3, 1, 2], 12),
        ([6, 2, 3, 8], 14),
        ([5, 8, 6, 1, 2, 9], 20),
        ([2, 1, 1, 2], 4),
        ([], 0),
        ([7], 7),
        ([4, 4], 4),
        ([0, 0, 0], 0),
        ([1, 3, 1, 3, 100], 103),
    ] as [([Int], Int)])
    func examples(houses: [Int], expected: Int) {
        #expect(QuietStreetHeist.maximumLoot(houses: houses) == expected)
    }

    @Test("Matches trying every plan on 400 small streets")
    func randomSmall() {
        var random = QuietStreetRandom(seed: 198)
        for _ in 0..<400 {
            let houses = (0..<Int.random(in: 0...16, using: &random)).map { _ in Int.random(in: 0...30, using: &random) }
            #expect(QuietStreetHeist.maximumLoot(houses: houses) == everyPlan(houses), "houses \(houses)")
        }
    }

    @Test("Streets of 100,000 houses")
    func large() {
        let alternating = (0..<100_000).map { $0 % 2 == 0 ? 10_000 : 1 }
        #expect(QuietStreetHeist.maximumLoot(houses: alternating) == 10_000 * 50_000)
        #expect(QuietStreetHeist.maximumLoot(houses: Array(repeating: 7, count: 99_999)) == 7 * 50_000)
        #expect(QuietStreetHeist.maximumLoot(houses: Array(repeating: 0, count: 100_000)) == 0)

        var random = QuietStreetRandom(seed: 100_000)
        for _ in 0..<3 {
            let houses = (0..<100_000).map { _ in Int.random(in: 0...10_000, using: &random) }
            #expect(QuietStreetHeist.maximumLoot(houses: houses) == robbedOrNot(houses))
        }
    }
}
