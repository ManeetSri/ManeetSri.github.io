import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CooldownRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StockTradesWithCooldownTests {
    /// Try every choice on every day: buy, sell, or wait
    private func everyPlan(_ prices: [Int]) -> Int {
        func trade(_ day: Int, holding: Int?, mayBuy: Bool) -> Int {
            if day == prices.count { return 0 }
            var best = trade(day + 1, holding: holding, mayBuy: true)                  // wait
            if let cost = holding {
                best = max(best, prices[day] - cost + trade(day + 1, holding: nil, mayBuy: false))   // sell
            } else if mayBuy {
                best = max(best, trade(day + 1, holding: prices[day], mayBuy: true))   // buy
            }
            return best
        }
        return trade(0, holding: nil, mayBuy: true)
    }

    /// A different method in O(n²): free[i] is the best profit from day i on, holding nothing and
    /// allowed to buy. Either wait, or buy on day i, sell on some later day j and resume at j + 2.
    private func quadratic(_ prices: [Int]) -> Int {
        let n = prices.count
        var free = Array(repeating: 0, count: n + 2)
        for i in stride(from: n - 1, through: 0, by: -1) {
            var best = free[i + 1]
            for j in (i + 1)..<n {
                best = max(best, prices[j] - prices[i] + free[j + 2])
            }
            free[i] = best
        }
        return free[0]
    }

    @Test("Examples and small cases", arguments: [
        ([3, 1, 4, 2, 5, 0, 3], 6),
        ([1, 3, 1, 3], 2),
        ([2, 9, 1, 8, 3, 7], 11),
        ([5, 4, 3, 2], 0),
        ([], 0),
        ([7], 0),
        ([1, 2], 1),
        ([4, 4, 4, 4], 0),
        ([1, 5, 2, 6], 5),
        ([1, 5, 5, 2, 6], 8),
    ] as [([Int], Int)])
    func examples(prices: [Int], expected: Int) {
        #expect(StockTradesWithCooldown.maxProfit(prices) == expected)
    }

    @Test("Matches trying every plan on 300 short random price lists")
    func randomSmall() {
        var random = CooldownRandom(seed: 309)
        for _ in 0..<300 {
            let prices = (0..<Int.random(in: 0...12, using: &random)).map { _ in Int.random(in: 0...20, using: &random) }
            #expect(StockTradesWithCooldown.maxProfit(prices) == everyPlan(prices))
        }
    }

    @Test("2,000 random days match an O(n²) method")
    func mediumRandom() {
        var random = CooldownRandom(seed: 2_000)
        let prices = (0..<2_000).map { _ in Int.random(in: 0...10_000, using: &random) }
        #expect(StockTradesWithCooldown.maxProfit(prices) == quadratic(prices))
    }

    @Test("100,000 days with known answers")
    func large() {
        // Low, high, high, repeated: each three-day block allows one trade (buy, sell, cool down)
        let blocks = 33_333
        let pattern = Array(repeating: [100, 9_000, 9_000], count: blocks).flatMap { $0 }
        #expect(StockTradesWithCooldown.maxProfit(pattern) == blocks * 8_900)

        // Rising every day: one long trade
        let rising = Array(0..<100_000)
        #expect(StockTradesWithCooldown.maxProfit(rising) == 99_999)

        // Falling every day: never trade
        let falling = Array((0..<100_000).reversed())
        #expect(StockTradesWithCooldown.maxProfit(falling) == 0)
    }
}
