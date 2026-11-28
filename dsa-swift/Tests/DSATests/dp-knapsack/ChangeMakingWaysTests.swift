import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ChangeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ChangeMakingWaysTests {
    private let mod = 1_000_000_007

    /// Brute force: choose how many of each coin to use, one coin value at a time
    private func bruteForce(_ coins: [Int], _ amount: Int, from index: Int = 0) -> Int {
        if index == coins.count { return amount == 0 ? 1 : 0 }
        var ways = 0
        var count = 0
        while count * coins[index] <= amount {
            ways += bruteForce(coins, amount - count * coins[index], from: index + 1)
            count += 1
        }
        return ways
    }

    /// The 2D table: ways[i][t] uses only the first i coins, and either skips coin i or uses one more of it
    private func table(_ coins: [Int], _ amount: Int) -> Int {
        var ways = Array(repeating: Array(repeating: 0, count: amount + 1), count: coins.count + 1)
        ways[0][0] = 1
        for i in stride(from: 1, through: coins.count, by: 1) {
            for total in 0...amount {
                ways[i][total] = ways[i - 1][total]
                if coins[i - 1] <= total {
                    ways[i][total] = (ways[i][total] + ways[i][total - coins[i - 1]]) % mod
                }
            }
        }
        return ways[coins.count][amount]
    }

    @Test("Examples and edge cases", arguments: [
        ([1, 2, 3], 4, 4),
        ([1, 2], 4, 3),
        ([2, 5], 3, 0),
        ([5], 0, 1),
        ([3, 7], 20, 1),
        ([7], 21, 1),
        ([2, 3], 12, 3),
        ([10, 20, 50], 100, 10),
        ([4], 100_000, 1),
    ] as [([Int], Int, Int)])
    func examples(coins: [Int], amount: Int, expected: Int) {
        #expect(ChangeMakingWays.count(coins: coins, amount: amount) == expected)
    }

    @Test("Matches brute force on 300 small random cases")
    func randomSmall() {
        var random = ChangeRandom(seed: 518)
        for _ in 0..<300 {
            var coins = Set<Int>()
            for _ in 0..<Int.random(in: 1...4, using: &random) {
                coins.insert(Int.random(in: 1...12, using: &random))
            }
            let list = coins.sorted().shuffled(using: &random)
            let amount = Int.random(in: 0...40, using: &random)
            #expect(ChangeMakingWays.count(coins: list, amount: amount) == bruteForce(list, amount), "\(list), \(amount)")
        }
    }

    @Test("Order of payment doesn't matter: closed forms for 1s, 2s and 3s")
    func closedForms() {
        // With 1s and 2s, choose how many 2s: 0 to n / 2
        #expect(ChangeMakingWays.count(coins: [1, 2], amount: 100_000) == 50_001)
        #expect(ChangeMakingWays.count(coins: [2, 1], amount: 99_999) == 50_000)
        // With 1s, 2s and 3s, the count is the nearest whole number to (n + 3)² / 12
        for n in [6, 1_000, 99_999, 100_000] {
            let expected = ((n + 3) * (n + 3) + 6) / 12
            #expect(ChangeMakingWays.count(coins: [3, 1, 2], amount: n) == expected, "amount \(n)")
        }
    }

    @Test("Large counts, modulo 1,000,000,007")
    func modulo() {
        #expect(ChangeMakingWays.count(coins: Array(1...50), amount: 5_000) == table(Array(1...50), 5_000))
        var random = ChangeRandom(seed: 7)
        var coins = Set<Int>()
        while coins.count < 30 {
            coins.insert(Int.random(in: 1...300, using: &random))
        }
        let list = Array(coins).sorted()
        let expected = table(list, 20_000)
        #expect(ChangeMakingWays.count(coins: list, amount: 20_000) == expected)
        #expect(ChangeMakingWays.count(coins: list.reversed(), amount: 20_000) == expected)
    }
}
