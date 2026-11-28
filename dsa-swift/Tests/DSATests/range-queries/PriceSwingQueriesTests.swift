import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SwingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PriceSwingQueriesTests {
    /// Scans each range: slow, but clearly right.
    private func reference(_ prices: [Int], _ query: [Int]) -> Int {
        let range = prices[query[0]...query[1]]
        return range.max()! - range.min()!
    }

    @Test("Examples", arguments: [
        ([7, 2, 9, 4, 8, 1, 6, 3], [[0, 7], [2, 4], [5, 5], [3, 6]], [8, 5, 0, 7]),
        ([10, 1, 10], [[0, 1], [1, 2], [0, 2]], [9, 9, 9]),
        ([3, 3, 3], [[0, 2], [1, 2]], [0, 0]),
        ([5], [[0, 0]], [0]),
        ([4, 7], [], []),
        ([0, 1_000_000_000], [[0, 1], [1, 1]], [1_000_000_000, 0]),
    ] as [([Int], [[Int]], [Int])])
    func examples(prices: [Int], queries: [[Int]], expected: [Int]) {
        #expect(PriceSwingQueries.swings(prices: prices, queries: queries) == expected)
    }

    @Test("Every range of every small array matches a scan")
    func allRangesSmall() {
        var random = SwingRandom(seed: 62)
        for n in 1...33 {
            let prices = (0..<n).map { _ in Int.random(in: 0...50, using: &random) }
            var queries: [[Int]] = []
            for left in 0..<n {
                for right in left..<n {
                    queries.append([left, right])
                }
            }
            queries.shuffle(using: &random)
            let answers = PriceSwingQueries.swings(prices: prices, queries: queries)
            #expect(answers.count == queries.count)
            guard answers.count == queries.count else { return }
            for (query, answer) in zip(queries, answers) where answer != reference(prices, query) {
                Issue.record("prices \(prices), query \(query): expected \(reference(prices, query)), got \(answer)")
                return
            }
        }
    }

    @Test("Ranges whose length is an exact power of two, and the whole array")
    func powerOfTwoLengths() {
        let prices = [9, 1, 8, 2, 7, 3, 6, 4, 5, 0, 10, 11, 12, 13, 14, 15]
        var queries: [[Int]] = []
        var length = 1
        while length <= prices.count {
            for start in 0...(prices.count - length) {
                queries.append([start, start + length - 1])
            }
            length *= 2
        }
        let expected = queries.map { reference(prices, $0) }
        #expect(PriceSwingQueries.swings(prices: prices, queries: queries) == expected)
    }

    @Test("100,000 queries over 100,000 prices")
    func large() {
        var random = SwingRandom(seed: 2_026)
        let n = 100_000
        let prices = (0..<n).map { _ in Int.random(in: 0...1_000_000_000, using: &random) }
        let queries = (0..<100_000).map { _ -> [Int] in
            let left = Int.random(in: 0..<(n / 10), using: &random)
            let right = Int.random(in: (n - n / 10)..<n, using: &random)
            return [left, right]
        }
        let answers = PriceSwingQueries.swings(prices: prices, queries: queries)
        #expect(answers.count == queries.count)
        guard answers.count == queries.count else { return }
        // Check a sample of the answers by scanning
        for index in stride(from: 0, to: queries.count, by: 4_999) {
            #expect(answers[index] == reference(prices, queries[index]))
        }
    }

    @Test("Increasing prices: the swing is the difference of the ends")
    func increasing() {
        let n = 50_000
        let prices = Array(0..<n).map { $0 * 3 }
        var random = SwingRandom(seed: 7)
        let queries = (0..<50_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            return [min(a, b), max(a, b)]
        }
        let expected = queries.map { 3 * ($0[1] - $0[0]) }
        #expect(PriceSwingQueries.swings(prices: prices, queries: queries) == expected)
    }
}
