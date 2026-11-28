import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TokenExchangeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TokenExchangeMachineTests {
    /// The answer for every value up to `limit`, filled bottom-up
    private func table(upTo limit: Int) -> [Int] {
        var best = Array(repeating: 0, count: limit + 1)
        for value in stride(from: 1, through: limit, by: 1) {
            best[value] = max(value, best[value / 2] + best[value / 3] + best[value / 4])
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        (0, 0),
        (1, 1),
        (5, 5),
        (11, 11),
        (24, 27),
        (100, 120),
        (1_000, 1_370),
        (1_000_000, 2_566_393),
    ])
    func examples(token: Int, expected: Int) {
        #expect(TokenExchangeMachine.mostCoins(token: token) == expected)
    }

    @Test("Every token up to 2,000, and 500 random ones up to 200,000")
    func againstTable() {
        let best = table(upTo: 200_000)
        for token in 0...2_000 {
            #expect(TokenExchangeMachine.mostCoins(token: token) == best[token], "token \(token)")
        }
        var random = TokenExchangeRandom(seed: 12)
        for _ in 0..<500 {
            let token = Int.random(in: 0...200_000, using: &random)
            #expect(TokenExchangeMachine.mostCoins(token: token) == best[token], "token \(token)")
        }
    }

    @Test("Tokens worth up to a trillion", arguments: [
        (1_000_000_000, 4_243_218_150),
        (123_456_789_012, 780_223_433_221),
        (999_999_999_999, 7_828_351_122_081),
        (1_000_000_000_000, 7_828_351_122_081),
    ])
    func huge(token: Int, expected: Int) {
        // Far too many for an array, and plain recursion makes trillions of calls
        #expect(TokenExchangeMachine.mostCoins(token: token) == expected)
    }
}
