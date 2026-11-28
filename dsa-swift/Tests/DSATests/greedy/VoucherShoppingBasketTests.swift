import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct VoucherRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct VoucherShoppingBasketTests {
    /// Try every basket, with the voucher on every item in it (or on none)
    private func everyBasket(_ prices: [Int], _ budget: Int) -> Int {
        var best = 0
        for mask in 0..<(1 << prices.count) {
            let basket = prices.indices.filter { mask & (1 << $0) != 0 }.map { prices[$0] }
            let total = basket.reduce(0, +)
            let biggestSaving = basket.map { $0 / 2 }.max() ?? 0
            if total - biggestSaving <= budget { best = max(best, basket.count) }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([40, 10, 25, 60, 5], 70, 4),
        ([30, 30, 30], 89, 3),
        ([30, 30, 30], 74, 2),
        ([100], 49, 0),
        ([100], 50, 1),
        ([7], 4, 1),                            // 7 halved, rounded up, is 4
        ([7], 3, 0),
        ([], 10, 0),
        ([1, 1, 1], 2, 2),                      // half of 1 rounds up to 1: no saving
        ([2, 3, 100], 4, 2),                    // the voucher goes on the 3, not the 100
        ([1], 0, 0),
        ([9, 8, 7, 6], 1_000, 4),
        ([5, 1, 4, 2, 3], 9, 4),                // 1 + 2 + 3 + 4 = 10, minus 2
    ] as [([Int], Int, Int)])
    func examples(prices: [Int], budget: Int, expected: Int) {
        #expect(VoucherShoppingBasket.mostItems(prices, budget: budget) == expected)
    }

    @Test("Matches trying every basket on 500 random shops")
    func randomSmall() {
        var random = VoucherRandom(seed: 50)
        for _ in 0..<500 {
            let prices = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: 1...30, using: &random) }
            let budget = Int.random(in: 0...120, using: &random)
            #expect(VoucherShoppingBasket.mostItems(prices, budget: budget) == everyBasket(prices, budget))
        }
    }

    @Test("200,000 items")
    func large() {
        var random = VoucherRandom(seed: 200_000)
        // Prices 1 to 200,000 in a shuffled order: k items cost 1 + 2 + … + k, minus k / 2
        let shuffled = Array(1...200_000).shuffled(using: &random)
        for budget in [0, 1, 2, 3, 1_000_000, 123_456_789, 20_000_000_000, 20_000_100_000] {
            var k = 0
            while k < 200_000 && (k + 1) * (k + 2) / 2 - (k + 1) / 2 <= budget { k += 1 }
            #expect(VoucherShoppingBasket.mostItems(shuffled, budget: budget) == k)
        }

        // Equal prices near the top of the range
        let equal = Array(repeating: 1_000_000_000, count: 200_000)
        #expect(VoucherShoppingBasket.mostItems(equal, budget: 100_000_000_000_000) == 100_000)
        #expect(VoucherShoppingBasket.mostItems(equal, budget: 99_999_500_000_000) == 100_000)
        #expect(VoucherShoppingBasket.mostItems(equal, budget: 99_999_499_999_999) == 99_999)
    }
}
