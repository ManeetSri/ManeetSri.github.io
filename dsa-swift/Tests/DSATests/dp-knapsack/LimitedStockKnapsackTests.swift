import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StockRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LimitedStockKnapsackTests {
    /// Brute force: choose how many copies of each kind to take, one kind at a time
    private func bruteForce(_ weights: [Int], _ values: [Int], _ stock: [Int], _ capacity: Int, from kind: Int = 0) -> Int {
        guard kind < weights.count else { return 0 }
        var best = 0
        var copies = 0
        while copies <= stock[kind] && copies * weights[kind] <= capacity {
            best = max(best, copies * values[kind] + bruteForce(weights, values, stock, capacity - copies * weights[kind], from: kind + 1))
            copies += 1
        }
        return best
    }

    /// One 0/1 item per copy: slow, but clearly right
    private func onePerCopy(_ weights: [Int], _ values: [Int], _ stock: [Int], _ capacity: Int) -> Int {
        var best = Array(repeating: 0, count: capacity + 1)
        for kind in weights.indices {
            for _ in 0..<min(stock[kind], capacity / weights[kind]) {
                for w in stride(from: capacity, through: weights[kind], by: -1) {
                    best[w] = max(best[w], best[w - weights[kind]] + values[kind])
                }
            }
        }
        return best[capacity]
    }

    /// The unbounded knapsack (left to right), which is the answer when no stock ever runs out
    private func unbounded(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Int {
        var best = Array(repeating: 0, count: capacity + 1)
        for (weight, value) in zip(weights, values) where weight <= capacity {
            for w in stride(from: weight, through: capacity, by: 1) {
                best[w] = max(best[w], best[w - weight] + value)
            }
        }
        return best[capacity]
    }

    @Test("Examples and edge cases", arguments: [
        ([2, 3], [3, 5], [3, 1], 9, 14),
        ([3, 4, 5], [4, 6, 7], [40, 5, 100], 200, 282),
        ([5], [9], [10], 23, 36),
        ([5], [9], [2], 23, 18),
        ([4, 1], [7, 1], [0, 3], 8, 3),
        ([6], [100], [5], 5, 0),
        ([1, 2], [5, 9], [4, 4], 0, 0),
        ([2, 2], [3, 4], [1, 1], 4, 7),
    ] as [([Int], [Int], [Int], Int, Int)])
    func examples(weights: [Int], values: [Int], stock: [Int], capacity: Int, expected: Int) {
        #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: stock, capacity: capacity) == expected)
    }

    @Test("Matches brute force on 300 small random cases")
    func randomSmall() {
        var random = StockRandom(seed: 63)
        for _ in 0..<300 {
            let n = Int.random(in: 1...4, using: &random)
            let weights = (0..<n).map { _ in Int.random(in: 1...10, using: &random) }
            let values = (0..<n).map { _ in Int.random(in: 0...20, using: &random) }
            let stock = (0..<n).map { _ in Int.random(in: 0...6, using: &random) }
            let capacity = Int.random(in: 0...35, using: &random)
            #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: stock, capacity: capacity)
                    == bruteForce(weights, values, stock, capacity), "\(weights) \(values) \(stock) \(capacity)")
        }
    }

    @Test("Matches one item per copy on medium cases")
    func medium() {
        var random = StockRandom(seed: 6_363)
        for _ in 0..<5 {
            let weights = (0..<20).map { _ in Int.random(in: 1...60, using: &random) }
            let values = (0..<20).map { _ in Int.random(in: 1...100, using: &random) }
            let stock = (0..<20).map { _ in Int.random(in: 0...40, using: &random) }
            #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: stock, capacity: 2_000)
                    == onePerCopy(weights, values, stock, 2_000))
        }
    }

    @Test("Stock of 1 is the 0/1 knapsack, and huge stock is the unbounded one")
    func extremes() {
        var random = StockRandom(seed: 99)
        let weights = (0..<60).map { _ in Int.random(in: 1...300, using: &random) }
        let values = (0..<60).map { _ in Int.random(in: 1...1_000, using: &random) }
        #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: Array(repeating: 1, count: 60), capacity: 10_000)
                == onePerCopy(weights, values, Array(repeating: 1, count: 60), 10_000))
        #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: Array(repeating: 100_000, count: 60), capacity: 10_000)
                == unbounded(weights, values, 10_000))
    }

    @Test("Large stocks: 60 kinds, up to 100,000 copies each, capacity 10,000")
    func largeStock() {
        // Two useful kinds and 58 worthless ones. With two kinds, try every count of the first and take as
        // many of the second as fit.
        var weights = [3, 7]
        var values = [10, 24]
        var stock = [2_000, 100_000]
        var random = StockRandom(seed: 1_234)
        for _ in 0..<58 {
            weights.append(Int.random(in: 1...20, using: &random))
            values.append(0)
            stock.append(100_000)
        }
        let capacity = 10_000
        var expected = 0
        for first in 0...min(stock[0], capacity / weights[0]) {
            let second = min(stock[1], (capacity - first * weights[0]) / weights[1])
            expected = max(expected, first * values[0] + second * values[1])
        }
        #expect(LimitedStockKnapsack.bestValue(weights: weights, values: values, stock: stock, capacity: capacity) == expected)

        // A single kind with a huge stock and a tiny weight
        #expect(LimitedStockKnapsack.bestValue(weights: [1], values: [3], stock: [100_000], capacity: 10_000) == 30_000)
        #expect(LimitedStockKnapsack.bestValue(weights: [1], values: [3], stock: [9_999], capacity: 10_000) == 29_997)
    }
}
