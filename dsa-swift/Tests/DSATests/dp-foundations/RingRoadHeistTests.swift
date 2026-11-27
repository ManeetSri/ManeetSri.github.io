import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RingRoadRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RingRoadHeistTests {
    /// Try every set of houses (as a bitmask) and keep the best that robs no two neighbours on the ring
    private func everyPlan(_ houses: [Int]) -> Int {
        let n = houses.count
        var best = 0
        for mask in 0..<(1 << n) {
            var total = 0
            var valid = true
            for i in 0..<n where mask & (1 << i) != 0 {
                let next = (i + 1) % n
                if next != i && mask & (1 << next) != 0 {
                    valid = false
                }
                total += houses[i]
            }
            if valid {
                best = max(best, total)
            }
        }
        return best
    }

    /// Fix whether house 0 is robbed, then run a straight-street DP that respects that choice at the end
    private func fixFirstHouse(_ houses: [Int]) -> Int {
        let n = houses.count
        if n == 0 {
            return 0
        }
        if n == 1 {
            return houses[0]
        }
        var best = 0
        for robFirst in [false, true] {
            var (robbed, notRobbed) = robFirst ? (houses[0], Int.min / 2) : (Int.min / 2, 0)
            for i in 1..<n {
                (robbed, notRobbed) = (notRobbed + houses[i], max(robbed, notRobbed))
            }
            // If house 0 was robbed, the last house must not be
            best = max(best, robFirst ? notRobbed : max(robbed, notRobbed))
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([5, 8, 6, 1, 2, 9], 18),
        ([7, 2, 4, 9], 11),
        ([6, 2, 3, 8], 10),
        ([4], 4),
        ([], 0),
        ([3, 5], 5),
        ([2, 7, 2], 7),
        ([2, 1, 1, 2], 3),
        ([1, 3, 1, 3, 100], 103),
        ([0, 0, 0], 0),
    ] as [([Int], Int)])
    func examples(houses: [Int], expected: Int) {
        #expect(RingRoadHeist.maximumLoot(houses: houses) == expected)
    }

    @Test("Matches trying every plan on 400 small rings")
    func randomSmall() {
        var random = RingRoadRandom(seed: 213)
        for _ in 0..<400 {
            let houses = (0..<Int.random(in: 0...12, using: &random)).map { _ in Int.random(in: 0...30, using: &random) }
            #expect(RingRoadHeist.maximumLoot(houses: houses) == everyPlan(houses), "houses \(houses)")
        }
    }

    @Test("Rings of about 100,000 houses")
    func large() {
        // Equal cash everywhere: an even ring can take every other house, an odd ring one fewer
        #expect(RingRoadHeist.maximumLoot(houses: Array(repeating: 9, count: 100_000)) == 9 * 50_000)
        #expect(RingRoadHeist.maximumLoot(houses: Array(repeating: 9, count: 99_999)) == 9 * 49_999)
        // The two richest houses are neighbours across the join
        var join = Array(repeating: 0, count: 100_000)
        join[0] = 10_000
        join[99_999] = 9_999
        #expect(RingRoadHeist.maximumLoot(houses: join) == 10_000)

        var random = RingRoadRandom(seed: 100_000)
        for _ in 0..<3 {
            let houses = (0..<100_000).map { _ in Int.random(in: 0...10_000, using: &random) }
            #expect(RingRoadHeist.maximumLoot(houses: houses) == fixFirstHouse(houses))
        }
    }
}
