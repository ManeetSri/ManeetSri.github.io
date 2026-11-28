import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StickerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StickerAlbumExpectedPacksTests {
    /// Inclusion–exclusion, which shares nothing with the DP: the expected wait for the last sticker is
    /// the sum over every non-empty set S of (-1)^(|S| + 1) / P(a pack is in S)
    private func reference(_ weights: [Int]) -> Double {
        let n = weights.count
        let total = Double(weights.reduce(0, +))
        var answer = 0.0
        for mask in 1..<(1 << n) {
            var chance = 0.0
            for i in 0..<n where mask & (1 << i) != 0 {
                chance += Double(weights[i]) / total
            }
            answer += (mask.nonzeroBitCount % 2 == 1 ? 1 : -1) / chance
        }
        return answer
    }

    private func close(_ actual: Double, _ expected: Double) -> Bool {
        abs(actual - expected) <= 1e-6 * max(1, abs(expected))
    }

    @Test("Examples and small cases", arguments: [
        ([5], 1.0),
        ([1, 1], 3.0),
        ([1, 3], 13.0 / 3),
        ([2, 2, 2], 5.5),
        ([1, 1, 1, 1, 1, 1], 14.7),
        ([1, 1, 2], 19.0 / 3),
    ] as [([Int], Double)])
    func examples(weights: [Int], expected: Double) {
        let answer = StickerAlbumExpectedPacks.expectedPacks(weights: weights)
        #expect(close(answer, expected), "got \(answer), expected \(expected)")
    }

    @Test("Equal weights give n times the nth harmonic number")
    func uniform() {
        for n in 1...16 {
            let harmonic = (1...n).reduce(0.0) { $0 + 1 / Double($1) }
            let answer = StickerAlbumExpectedPacks.expectedPacks(weights: [Int](repeating: 7, count: n))
            #expect(close(answer, Double(n) * harmonic), "n = \(n): got \(answer)")
        }
    }

    @Test("Matches inclusion–exclusion on 200 random albums")
    func randomSmall() {
        var random = StickerRandom(seed: 58)
        for _ in 0..<200 {
            let weights = (0..<Int.random(in: 1...10, using: &random)).map { _ in Int.random(in: 1...20, using: &random) }
            let answer = StickerAlbumExpectedPacks.expectedPacks(weights: weights)
            #expect(close(answer, reference(weights)), "\(weights): got \(answer)")
        }
    }

    @Test("Sixteen stickers, some very rare")
    func large() {
        var random = StickerRandom(seed: 2_058)
        for _ in 0..<3 {
            var weights = (0..<16).map { _ in Int.random(in: 1...1_000, using: &random) }
            weights[Int.random(in: 0..<16, using: &random)] = 1
            let answer = StickerAlbumExpectedPacks.expectedPacks(weights: weights)
            #expect(close(answer, reference(weights)), "\(weights): got \(answer)")
        }
    }
}
