import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SpiceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SpiceMarketBagfulTests {
    private func close(_ actual: Double, _ expected: Double) -> Bool {
        abs(actual - expected) <= 1e-6 * max(1, abs(expected))
    }

    /// Some best bagful splits at most one good, so try every set of whole goods plus, optionally,
    /// part of one more to fill the space that's left
    private func everyBagful(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Double {
        var best = 0.0
        for mask in 0..<(1 << weights.count) {
            let whole = weights.indices.filter { mask & (1 << $0) != 0 }
            let used = whole.reduce(0) { $0 + weights[$1] }
            if used > capacity { continue }
            let value = Double(whole.reduce(0) { $0 + values[$1] })
            best = max(best, value)
            for extra in weights.indices where mask & (1 << extra) == 0 {
                let take = min(weights[extra], capacity - used)
                best = max(best, value + Double(values[extra]) * Double(take) / Double(weights[extra]))
            }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([4, 6, 5, 8], [20, 18, 35, 8], 10, 58.0),             // the spice stall from the lesson
        ([3, 2], [10, 7], 2, 7.0),                             // 3.5 per kg beats 3.33, though 10 / 3 == 7 / 2 in Int
        ([4, 6, 5, 8], [20, 18, 35, 8], 0, 0.0),
        ([4, 6, 5, 8], [20, 18, 35, 8], 100, 81.0),            // everything fits
        ([], [], 10, 0.0),
        ([5], [0], 3, 0.0),
        ([3], [10], 1, 10.0 / 3.0),
        ([6, 5, 5], [30, 20, 20], 10, 46.0),                   // the lamp, then 4 kg of the rug
        ([1, 1, 1], [5, 5, 5], 2, 10.0),
        ([10, 1], [1, 2], 5, 2.4),
    ] as [([Int], [Int], Int, Double)])
    func examples(weights: [Int], values: [Int], capacity: Int, expected: Double) {
        #expect(close(SpiceMarketBagful.bestValue(weights: weights, values: values, capacity: capacity), expected))
    }

    @Test("Matches trying every set of whole goods plus one part on 500 random stalls")
    func randomSmall() {
        var random = SpiceRandom(seed: 58)
        for _ in 0..<500 {
            let count = Int.random(in: 0...7, using: &random)
            let weights = (0..<count).map { _ in Int.random(in: 1...12, using: &random) }
            let values = (0..<count).map { _ in Int.random(in: 0...40, using: &random) }
            let capacity = Int.random(in: 0...40, using: &random)
            #expect(close(SpiceMarketBagful.bestValue(weights: weights, values: values, capacity: capacity), everyBagful(weights, values, capacity)))
        }
    }

    @Test("200,000 goods")
    func large() {
        var random = SpiceRandom(seed: 200_000)
        let count = 200_000
        let weights = (0..<count).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        let values = (0..<count).map { _ in Int.random(in: 0...1_000_000, using: &random) }
        let capacity = weights.reduce(0, +) / 3
        // The same greedy with Double densities, as an independent check on random data
        let order = weights.indices.sorted { Double(values[$0]) / Double(weights[$0]) > Double(values[$1]) / Double(weights[$1]) }
        var room = capacity
        var expected = 0.0
        for good in order where room > 0 {
            let take = min(weights[good], room)
            expected += Double(values[good]) * Double(take) / Double(weights[good])
            room -= take
        }
        #expect(close(SpiceMarketBagful.bestValue(weights: weights, values: values, capacity: capacity), expected))

        // Every good worth exactly 7 per kilogram: the order doesn't matter, only the capacity
        let flat = weights.map { $0 * 7 }
        #expect(close(SpiceMarketBagful.bestValue(weights: weights, values: flat, capacity: 123_456_789), 7.0 * 123_456_789))
        #expect(close(SpiceMarketBagful.bestValue(weights: weights, values: flat, capacity: 1_000_000_000_000_000), 7.0 * Double(weights.reduce(0, +))))
    }
}
