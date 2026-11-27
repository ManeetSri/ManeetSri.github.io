import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same prices
private struct PriceBandRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PriceBandTotalsTests {
    /// The statement's slow version: scan every price for every band
    private func slow(_ prices: [Int], _ bands: [(low: Int, high: Int)]) -> [Int] {
        bands.map { band in prices.filter { band.low <= $0 && $0 <= band.high }.reduce(0, +) }
    }

    private let prices = [12, 5, 40, 5, 18, 27, 9]

    @Test("The statement's examples")
    func examples() {
        let bands: [(low: Int, high: Int)] = [(5, 12), (13, 26), (18, 40), (0, 100), (41, 50), (12, 12), (30, 20)]
        #expect(PriceBandTotals.totals(prices: prices, bands: bands) == [31, 18, 85, 116, 0, 12, 0])
    }

    @Test("Both ends of a band are included, and duplicates all count")
    func inclusiveEnds() {
        #expect(PriceBandTotals.totals(prices: [5, 5, 5, 6], bands: [(5, 5), (4, 5), (5, 6), (6, 9), (1, 4)]) == [15, 15, 21, 6, 0])
    }

    @Test("Empty inputs")
    func empty() {
        #expect(PriceBandTotals.totals(prices: [], bands: [(0, 10), (5, 1)]) == [0, 0])
        #expect(PriceBandTotals.totals(prices: [3, 4], bands: []) == [])
    }

    @Test("Refunds are negative prices, and bands can reach any Int")
    func negativesAndExtremes() {
        let prices = [-30, -5, 0, 7, 1_000_000_000, -1_000_000_000]
        let bands: [(low: Int, high: Int)] = [(-10, 10), (Int.min, -1), (1, Int.max), (Int.min, Int.max), (Int.max, Int.max), (0, Int.min)]
        #expect(PriceBandTotals.totals(prices: prices, bands: bands) == [2, -1_000_000_035, 1_000_000_007, -28, 0, 0])
    }

    @Test("A band whose low end is above its high end is empty")
    func backwardsBand() {
        #expect(PriceBandTotals.totals(prices: [1, 2, 3], bands: [(3, 1), (2, 2), (Int.max, Int.min)]) == [0, 2, 0])
    }

    @Test("Matches the slow version on random small inputs")
    func randomSmall() {
        var random = PriceBandRandom(seed: 71)
        var firstMismatch: String? = nil
        for _ in 0..<400 where firstMismatch == nil {
            let prices = (0..<Int.random(in: 0...15, using: &random)).map { _ in Int.random(in: -10...10, using: &random) }
            let bands: [(low: Int, high: Int)] = (0..<Int.random(in: 0...8, using: &random)).map { _ in
                (Int.random(in: -12...12, using: &random), Int.random(in: -12...12, using: &random))
            }
            let got = PriceBandTotals.totals(prices: prices, bands: bands)
            let expected = slow(prices, bands)
            if got != expected {
                firstMismatch = "prices \(prices), bands \(bands): got \(got), expected \(expected)"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("200,000 prices and 200,000 bands")
    func large() {
        // The prices are 1 ... 200,000 in a scrambled order, so a band's total is an arithmetic series.
        // The slow version would need 4 × 10^10 comparisons.
        let n = 200_000
        let prices = (0..<n).map { ($0 * 7_919) % n + 1 }
        var random = PriceBandRandom(seed: 2_024)
        var bands: [(low: Int, high: Int)] = []
        var expected: [Int] = []
        for _ in 0..<n {
            let a = Int.random(in: -5...(n + 5), using: &random)
            let b = Int.random(in: -5...(n + 5), using: &random)
            bands.append((a, b))
            let low = max(a, 1), high = min(b, n)
            expected.append(low <= high ? (low + high) * (high - low + 1) / 2 : 0)
        }
        #expect(PriceBandTotals.totals(prices: prices, bands: bands) == expected)
    }
}
