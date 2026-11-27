import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DuelRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CoinRowDuelTests {
    /// Plays out every possible game: the mover tries both ends and keeps whichever leaves them best off
    private func bruteForce(_ coins: ArraySlice<Int>) -> Int {
        guard let first = coins.first, let last = coins.last else { return 0 }
        if coins.count == 1 { return first }
        return max(first - bruteForce(coins.dropFirst()), last - bruteForce(coins.dropLast()))
    }

    /// The minimax recurrence, filled by range length, for long rows
    private func reference(_ coins: [Int]) -> Int {
        let n = coins.count
        guard n > 0 else { return 0 }
        var margin = Array(repeating: Array(repeating: 0, count: n), count: n)
        for i in 0..<n {
            margin[i][i] = coins[i]
        }
        if n >= 2 {
            for length in 2...n {
                for i in 0...(n - length) {
                    let j = i + length - 1
                    margin[i][j] = max(coins[i] - margin[i + 1][j], coins[j] - margin[i][j - 1])
                }
            }
        }
        return margin[0][n - 1]
    }

    @Test("Examples and edge cases", arguments: [
        ([3, 9, 1, 2], 7),
        ([2, 7, 3], -2),
        ([5, 1, 4], 2),
        ([4, 7, 2, 9, 5, 1], 6),
        ([8, 8], 0),
        ([6], 6),
        ([0, 0, 0], 0),
        ([], 0),
    ] as [([Int], Int)])
    func examples(coins: [Int], expected: Int) {
        #expect(CoinRowDuel.bestMargin(coins) == expected)
    }

    @Test("Matches playing out every game on 300 short rows")
    func randomSmall() {
        var random = DuelRandom(seed: 60)
        for _ in 0..<300 {
            let coins = (0..<Int.random(in: 0...13, using: &random)).map { _ in Int.random(in: 0...20, using: &random) }
            #expect(CoinRowDuel.bestMargin(coins) == bruteForce(coins[...]), "coins: \(coins)")
        }
    }

    @Test("1,000 coins")
    func large() {
        var random = DuelRandom(seed: 1_000)
        let coins = (0..<1_000).map { _ in Int.random(in: 0...1_000_000, using: &random) }
        let margin = CoinRowDuel.bestMargin(coins)
        #expect(margin == reference(coins))

        // With an even number of coins, the first player can take every coin at even positions or every
        // coin at odd positions, so perfect play does at least as well as the better of the two
        let evenTotal = stride(from: 0, to: coins.count, by: 2).reduce(0) { $0 + coins[$1] }
        let oddTotal = stride(from: 1, to: coins.count, by: 2).reduce(0) { $0 + coins[$1] }
        #expect(margin >= abs(evenTotal - oddTotal))

        // Equal coins: the players split them evenly
        #expect(CoinRowDuel.bestMargin(Array(repeating: 5, count: 1_000)) == 0)
        #expect(CoinRowDuel.bestMargin(Array(repeating: 5, count: 999)) == 5)
    }
}
