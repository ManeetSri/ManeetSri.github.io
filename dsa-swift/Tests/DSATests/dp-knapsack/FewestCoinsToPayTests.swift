import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CoinsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FewestCoinsToPayTests {
    /// Brute force: decide how many of each coin to use, one coin value at a time. Int.max means impossible.
    private func bruteForce(_ coins: [Int], _ amount: Int, from index: Int = 0) -> Int {
        if amount == 0 { return 0 }
        guard index < coins.count else { return Int.max }
        var best = Int.max
        var count = 0
        while count * coins[index] <= amount {
            let rest = bruteForce(coins, amount - count * coins[index], from: index + 1)
            if rest != Int.max { best = min(best, count + rest) }
            count += 1
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        ([1, 3, 4], 6, 2),
        ([1, 5, 6, 9], 11, 2),
        ([5, 7], 24, 4),
        ([4, 6], 9, -1),
        ([3], 0, 0),
        ([2], 1, -1),
        ([7], 7, 1),
        ([10, 1], 13, 4),
        ([100_000], 99_999, -1),
    ] as [([Int], Int, Int)])
    func examples(coins: [Int], amount: Int, expected: Int) {
        #expect(FewestCoinsToPay.fewest(coins: coins, amount: amount) == expected)
    }

    @Test("Matches brute force on 300 small random cases")
    func randomSmall() {
        var random = CoinsRandom(seed: 322)
        for _ in 0..<300 {
            let coins = (0..<Int.random(in: 1...4, using: &random)).map { _ in Int.random(in: 1...15, using: &random) }
            let amount = Int.random(in: 0...60, using: &random)
            let expected = bruteForce(coins, amount)
            #expect(FewestCoinsToPay.fewest(coins: coins, amount: amount) == (expected == Int.max ? -1 : expected), "\(coins), \(amount)")
        }
    }

    @Test("Amounts up to 100,000")
    func large() {
        // US coins are a system where biggest-first is always right: 3,999 quarters, 2 dimes and 4 pennies
        #expect(FewestCoinsToPay.fewest(coins: [25, 10, 5, 1], amount: 99_999) == 4_005)

        // Every coin is even, so an odd amount is impossible
        #expect(FewestCoinsToPay.fewest(coins: [4, 6, 10], amount: 99_999) == -1)

        // Two coins: try every number of the bigger coin
        for (small, big, amount) in [(7, 11, 100_000), (6, 9, 99_999), (97, 101, 99_000)] {
            var expected = Int.max
            var bigCount = 0
            while bigCount * big <= amount {
                let rest = amount - bigCount * big
                if rest % small == 0 { expected = min(expected, bigCount + rest / small) }
                bigCount += 1
            }
            #expect(FewestCoinsToPay.fewest(coins: [small, big], amount: amount) == (expected == Int.max ? -1 : expected), "\([small, big]), \(amount)")
        }

        // Biggest-first is wrong for these coins (11 = 9 + 1 + 1, but 5 + 6 is two coins); compare with BFS
        #expect(FewestCoinsToPay.fewest(coins: [1, 5, 6, 9], amount: 100_001) == fewestByBFS([1, 5, 6, 9], 100_001))
    }

    /// A different algorithm for the same answer: breadth-first search over amounts, where each coin is an
    /// edge. The first time BFS reaches an amount, it has used the fewest coins.
    private func fewestByBFS(_ coins: [Int], _ amount: Int) -> Int {
        var distance = Array(repeating: -1, count: amount + 1)
        distance[0] = 0
        var queue = [0]
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            for coin in coins where current + coin <= amount && distance[current + coin] == -1 {
                distance[current + coin] = distance[current] + 1
                queue.append(current + coin)
            }
        }
        return distance[amount]
    }

    @Test("Many coin values and an amount of 100,000, against BFS")
    func manyCoins() {
        var random = CoinsRandom(seed: 2_020)
        let coins = (0..<12).map { _ in Int.random(in: 50...5_000, using: &random) }
        for amount in [100_000, 49] {
            #expect(FewestCoinsToPay.fewest(coins: coins, amount: amount) == fewestByBFS(coins, amount), "\(amount)")
        }
        // Every coin a multiple of 3, apart from 1,000
        let threes = (1...19).map { $0 * 3 * 97 } + [1_000]
        #expect(FewestCoinsToPay.fewest(coins: threes, amount: 100_000) == fewestByBFS(threes, 100_000))
    }
}
