import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RentRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RentOrBuyLedgerTests {
    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    /// The worst ratio found by trying every shoot length up to well past both the price and the day
    private func bruteWorst(_ b: Int, _ t: Int) -> (Int, Int) {
        var worst = (0, 1)
        for d in 1...(b + t + 5) {
            let plan = d < t ? d : t - 1 + b
            let best = min(d, b)
            if plan * worst.1 > worst.0 * best { worst = (plan, best) }
        }
        let g = gcd(worst.0, worst.1)
        return (worst.0 / g, worst.1 / g)
    }

    @Test("The replay examples")
    func replayExamples() {
        let long = RentOrBuyLedger.replay(dailyRents: Array(repeating: 1, count: 12), buyPrice: 10)
        #expect(long.online == 19 && long.hindsight == 10 && long.buyDay == 10)
        let short = RentOrBuyLedger.replay(dailyRents: [1, 1, 1, 1, 1], buyPrice: 10)
        #expect(short.online == 5 && short.hindsight == 5 && short.buyDay == nil)
        let varying = RentOrBuyLedger.replay(dailyRents: [3, 4, 5, 2], buyPrice: 10)
        #expect(varying.online == 17 && varying.hindsight == 10 && varying.buyDay == 3)
        let dear = RentOrBuyLedger.replay(dailyRents: [12], buyPrice: 10)
        #expect(dear.online == 10 && dear.hindsight == 10 && dear.buyDay == 1)
        let none = RentOrBuyLedger.replay(dailyRents: [], buyPrice: 10)
        #expect(none.online == 0 && none.hindsight == 0 && none.buyDay == nil)
    }

    @Test("Rent that reaches the price exactly triggers the purchase")
    func exactlyReaching() {
        let result = RentOrBuyLedger.replay(dailyRents: [4, 6, 1], buyPrice: 10)
        #expect(result.online == 14 && result.hindsight == 10 && result.buyDay == 2)
        let underneath = RentOrBuyLedger.replay(dailyRents: [4, 5], buyPrice: 10)
        #expect(underneath.online == 9 && underneath.hindsight == 9 && underneath.buyDay == nil)
    }

    @Test("Random shoots: the rule never pays twice what hindsight pays")
    func competitive() {
        var random = RentRandom(seed: 67)
        for _ in 0..<500 {
            let price = Int.random(in: 1...50, using: &random)
            let rents = (0..<Int.random(in: 0...30, using: &random)).map { _ in Int.random(in: 1...12, using: &random) }
            let result = RentOrBuyLedger.replay(dailyRents: rents, buyPrice: price)
            // Replay the rule independently
            var paid = 0
            var day: Int? = nil
            for (index, rent) in rents.enumerated() {
                if paid + rent >= price {
                    paid += price
                    day = index + 1
                    break
                }
                paid += rent
            }
            let hindsight = min(rents.reduce(0, +), price)
            let matches = result.online == paid && result.hindsight == hindsight && result.buyDay == day
            #expect(matches, "rents \(rents), price \(price)")
            #expect(result.online < 2 * max(1, hindsight) || rents.isEmpty)
            if !matches { return }
        }
    }

    @Test("Worst ratios for fixed plans", arguments: [
        (10, 10, 19, 10), (10, 1, 10, 1), (10, 15, 12, 5), (1, 1, 1, 1), (2, 2, 3, 2), (10, 5, 14, 5),
        (1_000_000_000, 1_000_000_000, 1_999_999_999, 1_000_000_000), (5, 1_000_000_000, 1_000_000_004, 5),
    ])
    func worstRatios(price: Int, day: Int, numerator: Int, denominator: Int) {
        let ratio = RentOrBuyLedger.worstRatio(buyPrice: price, buyDay: day)
        #expect(ratio.numerator == numerator && ratio.denominator == denominator)
    }

    @Test("Worst ratios match trying every shoot length")
    func worstBrute() {
        for price in 1...25 {
            for day in 1...40 {
                let ratio = RentOrBuyLedger.worstRatio(buyPrice: price, buyDay: day)
                let expected = bruteWorst(price, day)
                #expect(ratio.numerator == expected.0 && ratio.denominator == expected.1, "price \(price), day \(day)")
                if ratio.numerator != expected.0 || ratio.denominator != expected.1 { return }
            }
        }
        // Buying on day B is the best fixed plan: (2B − 1) / B
        for price in 2...25 {
            let best = (1...60).map { RentOrBuyLedger.worstRatio(buyPrice: price, buyDay: $0) }
                .min { $0.numerator * $1.denominator < $1.numerator * $0.denominator }
            #expect(best?.numerator == 2 * price - 1 && best?.denominator == price)
        }
    }

    @Test("A 100,000-day shoot")
    func large() {
        let rents = (0..<100_000).map { $0 % 7 + 1 }
        let total = rents.reduce(0, +)
        let cheap = RentOrBuyLedger.replay(dailyRents: rents, buyPrice: total + 1)
        #expect(cheap.online == total && cheap.hindsight == total && cheap.buyDay == nil)
        let dear = RentOrBuyLedger.replay(dailyRents: rents, buyPrice: 200_000)
        #expect(dear.hindsight == 200_000)
        #expect(dear.buyDay != nil && dear.online < 400_000 && dear.online >= 200_000)
    }
}
