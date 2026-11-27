import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BundleRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct GiftBundleSubsetsTests {
    /// Sorts the prices in each bundle, then the bundles, so answers in any order compare equal
    private func canonical(_ bundles: [[Int]]) -> [[Int]] {
        bundles.map { $0.sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
    }

    /// Every mask of the prices, with repeats thrown away: slow, but clearly right
    private func reference(_ prices: [Int]) -> [[Int]] {
        var seen = Set<[Int]>()
        for mask in 0..<(1 << prices.count) {
            seen.insert(prices.indices.filter { mask & (1 << $0) != 0 }.map { prices[$0] }.sorted())
        }
        return canonical(Array(seen))
    }

    @Test("Examples and small cases", arguments: [
        ([5, 8, 5], [[], [5], [8], [5, 5], [5, 8], [5, 5, 8]]),
        ([4, 4, 4], [[], [4], [4, 4], [4, 4, 4]]),
        ([9], [[], [9]]),
        ([], [[]]),
        ([1, 2, 3], [[], [1], [2], [3], [1, 2], [1, 3], [2, 3], [1, 2, 3]]),
        ([6, 2, 6, 2], [[], [2], [6], [2, 2], [2, 6], [6, 6], [2, 2, 6], [2, 6, 6], [2, 2, 6, 6]]),
    ] as [([Int], [[Int]])])
    func examples(prices: [Int], expected: [[Int]]) {
        #expect(canonical(GiftBundleSubsets.bundles(prices)) == canonical(expected))
    }

    @Test("Matches brute force on 300 random price lists")
    func randomSmall() {
        var random = BundleRandom(seed: 48)
        for _ in 0..<300 {
            let prices = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: 1...4, using: &random) }
            #expect(canonical(GiftBundleSubsets.bundles(prices)) == reference(prices), "prices \(prices)")
        }
    }

    @Test("24 prices in two runs of 12: only 169 bundles, so trying all 2^24 masks is far too slow")
    func manyRepeats() {
        var random = BundleRandom(seed: 2_048)
        let prices = (Array(repeating: 7, count: 12) + Array(repeating: 3, count: 12)).shuffled(using: &random)
        let expected = (0...12).flatMap { threes in
            (0...12).map { sevens in Array(repeating: 3, count: threes) + Array(repeating: 7, count: sevens) }
        }
        #expect(canonical(GiftBundleSubsets.bundles(prices)) == canonical(expected))
    }

    @Test("16 different prices give all 65,536 bundles, each once")
    func allDifferent() {
        let prices = (1...16).map { $0 * 3 }
        let result = GiftBundleSubsets.bundles(prices)
        #expect(result.count == 65_536)
        #expect(Set(result.map { $0.sorted() }).count == 65_536)
        #expect(result.allSatisfy { bundle in Set(bundle).count == bundle.count && bundle.allSatisfy { $0 % 3 == 0 && $0 <= 48 } })
    }
}
