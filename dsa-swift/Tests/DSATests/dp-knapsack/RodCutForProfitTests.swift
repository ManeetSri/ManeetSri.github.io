import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RodRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RodCutForProfitTests {
    /// Brute force: decide how many pieces of each offer to cut, one offer at a time
    private func bruteForce(_ length: Int, _ offers: [[Int]], from index: Int = 0) -> Int {
        guard index < offers.count else { return 0 }
        let piece = offers[index][0]
        let price = offers[index][1]
        var best = 0
        var count = 0
        while count * piece <= length {
            best = max(best, count * price + bruteForce(length - count * piece, offers, from: index + 1))
            count += 1
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        (7, [[2, 5], [3, 9]], 19),
        (8, [[1, 2], [2, 5], [3, 9], [4, 11], [5, 14], [6, 17], [7, 20], [8, 22]], 23),
        (10, [[4, 9]], 18),
        (5, [[6, 100]], 0),
        (0, [[1, 5]], 0),
        (6, [[3, 4], [3, 7]], 14),
        (9, [[4, 10], [5, 13]], 23),
        (12, [[5, 0], [7, 0]], 0),
    ] as [(Int, [[Int]], Int)])
    func examples(length: Int, offers: [[Int]], expected: Int) {
        #expect(RodCutForProfit.bestPrice(length: length, offers: offers) == expected)
    }

    @Test("Matches brute force on 300 short rods")
    func randomSmall() {
        var random = RodRandom(seed: 131)
        for _ in 0..<300 {
            let length = Int.random(in: 0...25, using: &random)
            let offers = (0..<Int.random(in: 1...4, using: &random)).map { _ in
                [Int.random(in: 1...10, using: &random), Int.random(in: 0...30, using: &random)]
            }
            #expect(RodCutForProfit.bestPrice(length: length, offers: offers) == bruteForce(length, offers), "\(length), \(offers)")
        }
    }

    @Test("A rod of 100,000 with two offers: an independent count")
    func twoOffers() {
        // With two offers, try every number of the first piece and fill the rest with the second
        let length = 100_000
        for (a, pa, b, pb) in [(7, 50, 11, 79), (13, 1_000, 17, 1_309), (999, 1_000_000, 1_000, 1_000_999)] {
            var expected = 0
            var count = 0
            while count * a <= length {
                expected = max(expected, count * pa + (length - count * a) / b * pb)
                count += 1
            }
            #expect(RodCutForProfit.bestPrice(length: length, offers: [[a, pa], [b, pb]]) == expected, "\([a, pa, b, pb])")
        }
    }

    @Test("A rod of 100,000 with 50 offers and one clear winner")
    func fiftyOffers() {
        // Length 8 earns 25 per unit and 8 divides the rod, so 12,500 of them is best: no plan can beat
        // 25 per unit, and every other offer earns at most 24 per unit
        var random = RodRandom(seed: 5_000)
        var offers = (0..<49).map { _ -> [Int] in
            let piece = Int.random(in: 1...5_000, using: &random)
            return [piece, piece * Int.random(in: 1...24, using: &random)]
        }
        offers.insert([8, 200], at: 25)
        #expect(RodCutForProfit.bestPrice(length: 100_000, offers: offers) == 12_500 * 200)
    }
}
