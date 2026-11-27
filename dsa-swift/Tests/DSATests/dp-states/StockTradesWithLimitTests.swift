import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct LimitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StockTradesWithLimitTests {
    /// Try every plan: on each day wait, or buy (if a trade is left), or sell what you hold
    private func everyPlan(_ prices: [Int], _ tradesLeft: Int) -> Int {
        func trade(_ day: Int, holding: Int?, left: Int) -> Int {
            if day == prices.count { return 0 }
            var best = trade(day + 1, holding: holding, left: left)
            if let cost = holding {
                // Sell, and maybe buy again the same day
                best = max(best, prices[day] - cost + trade(day + 1, holding: nil, left: left))
                if left > 0 {
                    best = max(best, prices[day] - cost + trade(day + 1, holding: prices[day], left: left - 1))
                }
            } else if left > 0 {
                best = max(best, trade(day + 1, holding: prices[day], left: left - 1))
            }
            return best
        }
        return trade(0, holding: nil, left: tradesLeft)
    }

    private func everyRise(_ prices: [Int]) -> Int {
        zip(prices, prices.dropFirst()).reduce(0) { $0 + max(0, $1.1 - $1.0) }
    }

    @Test("Examples and small cases", arguments: [
        ([2, 6, 3, 1, 5, 4, 8, 2], 2, 11),
        ([2, 6, 3, 1, 5, 4, 8, 2], 1, 7),
        ([2, 6, 3, 1, 5, 4, 8, 2], 3, 12),
        ([1, 2, 3, 4, 5], 1, 4),
        ([5, 4, 3], 2, 0),
        ([], 3, 0),
        ([4, 9], 0, 0),
        ([4, 9], 1, 5),
        ([7], 5, 0),
        ([3, 8, 2, 5, 1, 4], 2, 8),
        ([3, 8, 2, 5, 1, 4], 1_000_000_000, 11),
    ] as [([Int], Int, Int)])
    func examples(prices: [Int], maxTrades: Int, expected: Int) {
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: maxTrades) == expected)
    }

    @Test("Matches trying every plan on 400 short random price lists")
    func randomSmall() {
        var random = LimitRandom(seed: 188)
        for _ in 0..<400 {
            let prices = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: 0...20, using: &random) }
            let limit = Int.random(in: 0...4, using: &random)
            #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: limit) == everyPlan(prices, limit))
        }
    }

    @Test("Peaks between zeros: the best k trades take the k biggest peaks")
    func peaks() {
        // Prices 0, g1, 0, g2, …: a trade earns at most the highest peak it covers, so with k trades
        // the best plan sells at each of the k biggest peaks separately
        var random = LimitRandom(seed: 2_000)
        let gains = (0..<1_000).map { _ in Int.random(in: 1...10_000, using: &random) }
        let prices = gains.flatMap { [0, $0] }
        let sorted = gains.sorted(by: >)
        for limit in [1, 2, 7, 300, 999] {
            #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: limit) == sorted.prefix(limit).reduce(0, +))
        }
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 1_000) == gains.reduce(0, +))
    }

    @Test("A huge limit on 100,000 days: the limit can't bind, so bank every rise")
    func hugeLimit() {
        var random = LimitRandom(seed: 100_000)
        let prices = (0..<100_000).map { _ in Int.random(in: 0...10_000, using: &random) }
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 1_000_000_000) == everyRise(prices))
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 50_000) == everyRise(prices))
    }

    @Test("Limits just below and at n / 2 agree when there are few rises")
    func aroundHalf() {
        // 20 days that rise on alternate days: 10 rises need 10 trades
        let prices = (0..<20).map { $0 % 2 == 0 ? 1 : 6 }
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 10) == 50)
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 9) == 45)
        #expect(StockTradesWithLimit.maxProfit(prices, maxTrades: 3) == 15)
    }
}
