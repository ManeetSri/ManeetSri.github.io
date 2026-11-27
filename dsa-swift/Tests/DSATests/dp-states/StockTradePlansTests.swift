import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TradePlanRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StockTradePlansTests {
    /// Try every plan: each day, wait, or buy (if free and a trade is left), or sell (if holding)
    private func everyPlan(_ prices: [Int], trades: Int) -> Int {
        func best(_ day: Int, holding: Int?, left: Int) -> Int {
            if day == prices.count { return 0 }
            var result = best(day + 1, holding: holding, left: left)                          // wait
            if let cost = holding {
                // Sell, and maybe buy again the same day
                result = max(result, prices[day] - cost + best(day, holding: nil, left: left))
            } else if left > 0 {
                result = max(result, best(day + 1, holding: prices[day], left: left - 1))      // buy
            }
            return result
        }
        return best(0, holding: nil, left: trades)
    }

    @Test("Examples and small cases", arguments: [
        ([9, 4, 7, 2, 8, 5], 6, 9),
        ([1, 2, 3, 4, 5], 4, 4),
        ([6, 5, 4], 0, 0),
        ([], 0, 0),
        ([7], 0, 0),
        ([3, 3, 3], 0, 0),
        ([1, 5, 2, 6], 5, 8),
        ([2, 1, 4], 3, 3),
        ([1, 10, 1, 10], 9, 18),
        ([5, 1, 9, 0, 3], 8, 11),
        ([10, 1, 2, 1, 2], 1, 2),
    ] as [([Int], Int, Int)])
    func examples(prices: [Int], oneTrade: Int, anyTrades: Int) {
        let best = StockTradePlans.bestProfits(prices)
        #expect(best.oneTrade == oneTrade)
        #expect(best.anyTrades == anyTrades)
    }

    @Test("Matches trying every plan on 300 short random price lists")
    func randomSmall() {
        var random = TradePlanRandom(seed: 57)
        for _ in 0..<300 {
            let prices = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: 0...20, using: &random) }
            let best = StockTradePlans.bestProfits(prices)
            #expect(best.oneTrade == everyPlan(prices, trades: 1))
            #expect(best.anyTrades == everyPlan(prices, trades: prices.count))
        }
    }

    @Test("2,000 random days match every pair of days, and every rise banked")
    func mediumRandom() {
        var random = TradePlanRandom(seed: 2_000)
        let prices = (0..<2_000).map { _ in Int.random(in: 0...10_000, using: &random) }
        var bestPair = 0
        for buy in prices.indices {
            for sell in buy..<prices.count {
                bestPair = max(bestPair, prices[sell] - prices[buy])
            }
        }
        let rises = zip(prices, prices.dropFirst()).reduce(0) { $0 + max(0, $1.1 - $1.0) }
        let best = StockTradePlans.bestProfits(prices)
        #expect(best.oneTrade == bestPair)
        #expect(best.anyTrades == rises)
    }

    @Test("100,000 days with known answers")
    func large() {
        let rising = Array(0..<100_000)
        let up = StockTradePlans.bestProfits(rising)
        #expect(up.oneTrade == 99_999 && up.anyTrades == 99_999)
        let down = StockTradePlans.bestProfits(Array(rising.reversed()))
        #expect(down.oneTrade == 0 && down.anyTrades == 0)
        // Low, high, low, high: one trade earns one swing, unlimited trades earn every swing
        let zigzag = StockTradePlans.bestProfits((0..<100_000).map { $0 % 2 == 0 ? 0 : 10_000 })
        #expect(zigzag.oneTrade == 10_000 && zigzag.anyTrades == 50_000 * 10_000)
        // The highest price comes first and the lowest last: max minus min would say 10,000
        let trap = StockTradePlans.bestProfits([10_000] + Array(repeating: 5_000, count: 99_998) + [0])
        #expect(trap.oneTrade == 0 && trap.anyTrades == 0)
    }
}
