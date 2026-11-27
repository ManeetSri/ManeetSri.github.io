import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ChangeBreakerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct GreedyChangeBreakerTests {
    /// Compare greedy with the true minimum for every amount up to `limit`, without relying on any bound
    private func reference(_ coins: [Int], upTo limit: Int) -> Int? {
        let biggestFirst = coins.sorted(by: >)
        var fewest = [0]
        for amount in stride(from: 1, through: limit, by: 1) {
            fewest.append(1 + coins.filter { $0 <= amount }.map { fewest[amount - $0] }.min()!)
            var left = amount
            var greedy = 0
            for coin in biggestFirst {
                greedy += left / coin
                left %= coin
            }
            if greedy > fewest[amount] { return amount }
        }
        return nil
    }

    @Test("Examples and small cases", arguments: [
        ([1, 3, 4], 6 as Int?),
        ([1, 2, 5, 10, 20, 50], nil),
        ([1, 3, 6, 12, 24, 30], 48),          // British coins before 1971
        ([1], nil),
        ([4, 1, 3], 6),                       // any order
        ([1, 5, 10, 25], nil),
        ([1, 7, 10], 14),
        ([1, 2], nil),
        ([1, 10, 25], 30),
        ([1, 2, 4, 5], 8),
        ([1, 5, 12], 15),
    ] as [([Int], Int?)])
    func examples(coins: [Int], expected: Int?) {
        #expect(GreedyChangeBreaker.smallestFailure(coins) == expected)
    }

    @Test("Matches checking every amount far past the bound on 400 random coin systems")
    func randomSmall() {
        var random = ChangeBreakerRandom(seed: 1_994)
        for _ in 0..<400 {
            var coins: Set<Int> = [1]
            for _ in 0..<Int.random(in: 0...4, using: &random) {
                coins.insert(Int.random(in: 2...30, using: &random))
            }
            let list = Array(coins).shuffled(using: &random)
            #expect(GreedyChangeBreaker.smallestFailure(list) == reference(list, upTo: 2 * list.max()! + 50))
        }
    }

    @Test("Large coins: the first failure can sit right below the bound")
    func large() {
        // 100,000 = 100,000 and 99,999 = 99,999 are each one coin, but 199,998 is two 99,999s,
        // while greedy takes 100,000 and then 99,998 ones
        #expect(GreedyChangeBreaker.smallestFailure([1, 99_999, 100_000]) == 199_998)
        #expect(GreedyChangeBreaker.smallestFailure([100_000, 1, 99_999]) == 199_998)

        let euroStyle = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000, 20_000, 50_000, 100_000]
        #expect(GreedyChangeBreaker.smallestFailure(euroStyle) == nil)
        let powersOfTwo = (0...16).map { 1 << $0 }
        #expect(GreedyChangeBreaker.smallestFailure(powersOfTwo.reversed()) == nil)
        #expect(GreedyChangeBreaker.smallestFailure([1, 30_000, 70_000, 99_000]) == reference([1, 30_000, 70_000, 99_000], upTo: 200_000))
    }
}
