import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BoatRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RescueBoatPairsTests {
    /// The fewest boats for every set of people, as a bitmask: the lowest person still waiting goes
    /// alone or with anyone else who fits. O(2ⁿ · n), so only for a few people.
    private func exhaustive(_ weights: [Int], _ limit: Int) -> Int {
        let n = weights.count
        var fewest = Array(repeating: Int.max, count: 1 << n)
        fewest[0] = 0
        for mask in 1..<(1 << n) {
            let first = mask.trailingZeroBitCount
            let rest = mask & ~(1 << first)
            fewest[mask] = fewest[rest] + 1                       // alone
            for other in 0..<n where rest & (1 << other) != 0 && weights[first] + weights[other] <= limit {
                fewest[mask] = min(fewest[mask], fewest[rest & ~(1 << other)] + 1)
            }
        }
        return fewest[(1 << n) - 1]
    }

    @Test("Examples and small cases", arguments: [
        ([3, 5, 3, 4, 2, 1], 5, 4),
        ([4, 2, 3, 5, 1, 6], 6, 4),
        ([3], 6, 1),
        ([], 10, 0),
        ([2, 2, 2, 2], 4, 2),
        ([2, 2, 2, 2], 3, 4),
        ([1, 9, 1, 9], 10, 2),
        ([5, 5, 5], 10, 2),
        ([1, 1, 1, 1, 1], 100, 3),
        ([7, 3, 6, 4], 10, 2),
    ] as [([Int], Int, Int)])
    func examples(weights: [Int], limit: Int, expected: Int) {
        #expect(RescueBoatPairs.boatsNeeded(weights, limit: limit) == expected)
    }

    @Test("Matches an exhaustive search on 500 small random groups")
    func randomSmall() {
        var random = BoatRandom(seed: 50)
        for _ in 0..<500 {
            let limit = Int.random(in: 1...12, using: &random)
            let weights = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: 1...limit, using: &random) }
            #expect(RescueBoatPairs.boatsNeeded(weights, limit: limit) == exhaustive(weights, limit),
                    "weights \(weights), limit \(limit)")
        }
    }

    @Test("100,000 people")
    func large() {
        var random = BoatRandom(seed: 2_026)
        let n = 100_000
        let limit = 30_000
        // 50,000 planted pairs that each fill a boat exactly: no plan can beat n / 2
        var pairs: [Int] = []
        for _ in 0..<(n / 2) {
            let weight = Int.random(in: 1..<limit, using: &random)
            pairs += [weight, limit - weight]
        }
        pairs.shuffle(using: &random)
        #expect(RescueBoatPairs.boatsNeeded(pairs, limit: limit) == n / 2)

        // Everyone heavier than half the limit: nobody can share
        let heavy = (0..<n).map { _ in Int.random(in: (limit / 2 + 1)...limit, using: &random) }
        #expect(RescueBoatPairs.boatsNeeded(heavy, limit: limit) == n)

        // Half light, half heavy, and every light person fits with every heavy one
        let mixed = (0..<n).map { $0 % 2 == 0 ? 10_000 : 20_000 }.shuffled(using: &random)
        #expect(RescueBoatPairs.boatsNeeded(mixed, limit: limit) == n / 2)
        #expect(RescueBoatPairs.boatsNeeded(Array(repeating: 1, count: n - 1), limit: limit) == n / 2)
    }
}
