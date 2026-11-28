import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BackpackRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HikingBackpackPackingTests {
    /// Brute force: the best total value over every subset that fits
    private func bruteForceBest(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Int {
        var best = 0
        for mask in 0..<(1 << weights.count) {
            var weight = 0
            var value = 0
            for i in weights.indices where mask & (1 << i) != 0 {
                weight += weights[i]
                value += values[i]
            }
            if weight <= capacity { best = max(best, value) }
        }
        return best
    }

    /// The best value alone, from a one-row knapsack
    private func bestValue(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Int {
        var best = Array(repeating: 0, count: capacity + 1)
        for (weight, value) in zip(weights, values) where weight <= capacity {
            for w in stride(from: capacity, through: weight, by: -1) {
                best[w] = max(best[w], best[w - weight] + value)
            }
        }
        return best[capacity]
    }

    /// The packing must list distinct indexes in increasing order, fit, and be worth `expected`
    private func check(_ weights: [Int], _ values: [Int], _ capacity: Int, expected: Int,
                       sourceLocation: SourceLocation = #_sourceLocation) {
        let packed = HikingBackpackPacking.bestPack(weights: weights, values: values, capacity: capacity)
        #expect(zip(packed, packed.dropFirst()).allSatisfy { $0 < $1 }, "indexes must be increasing: \(packed)", sourceLocation: sourceLocation)
        #expect(packed.allSatisfy { weights.indices.contains($0) }, "index out of range in \(packed)", sourceLocation: sourceLocation)
        guard packed.allSatisfy({ weights.indices.contains($0) }) else { return }
        #expect(packed.map { weights[$0] }.reduce(0, +) <= capacity, "the packing is too heavy", sourceLocation: sourceLocation)
        #expect(packed.map { values[$0] }.reduce(0, +) == expected, "the packing isn't worth the most possible", sourceLocation: sourceLocation)
    }

    @Test("Examples and edge cases", arguments: [
        ([4, 2, 3, 5], [10, 4, 7, 11], 9, 21),
        ([1, 3, 4, 5], [1, 4, 5, 7], 7, 9),
        ([6, 6], [5, 8], 5, 0),
        ([], [], 10, 0),
        ([3], [4], 3, 4),
        ([3], [4], 0, 0),
        ([2, 2, 2], [3, 3, 3], 5, 6),
        ([5, 4, 6, 3], [10, 40, 30, 50], 10, 90),
        ([7, 3, 4, 2], [9, 5, 6, 2], 9, 13),
    ] as [([Int], [Int], Int, Int)])
    func examples(weights: [Int], values: [Int], capacity: Int, expected: Int) {
        check(weights, values, capacity, expected: expected)
    }

    @Test("Matches brute force on 300 small random backpacks")
    func randomSmall() {
        var random = BackpackRandom(seed: 53)
        for _ in 0..<300 {
            let n = Int.random(in: 0...10, using: &random)
            let weights = (0..<n).map { _ in Int.random(in: 1...15, using: &random) }
            let values = (0..<n).map { _ in Int.random(in: 1...20, using: &random) }
            let capacity = Int.random(in: 0...40, using: &random)
            check(weights, values, capacity, expected: bruteForceBest(weights, values, capacity))
        }
    }

    @Test("Greedy by value per weight is not enough")
    func greedyTrap() {
        // The densest item (weight 6, value 13) leaves 4 units nobody can use; 5 + 5 is worth more
        check([6, 5, 5], [13, 10, 10], 10, expected: 20)
    }

    @Test("100 items and a capacity of 10,000")
    func large() {
        var random = BackpackRandom(seed: 2_053)
        let weights = (0..<100).map { _ in Int.random(in: 1...1_000, using: &random) }
        let values = (0..<100).map { _ in Int.random(in: 1...1_000, using: &random) }
        for capacity in [10_000, 1] {
            check(weights, values, capacity, expected: bestValue(weights, values, capacity))
        }
    }
}
