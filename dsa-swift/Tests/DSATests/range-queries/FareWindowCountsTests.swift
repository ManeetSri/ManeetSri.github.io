import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same fares
private struct FareRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FareWindowCountsTests {
    /// Scans the range: slow, but clearly right.
    private func reference(_ fares: [Int], _ query: [Int]) -> Int {
        fares[query[0]...query[1]].filter { query[2] <= $0 && $0 <= query[3] }.count
    }

    @Test("Examples", arguments: [
        ([5, 2, 8, 6, 3, 9, 1, 7], [[0, 7, 3, 6], [2, 5, 6, 9], [1, 3, 1, 1], [0, 7, 0, 100]], [3, 3, 0, 8]),
        ([4, 4, 4], [[0, 2, 4, 4], [1, 1, 5, 9], [0, 1, 0, 3]], [3, 0, 0]),
        ([10], [[0, 0, 10, 10]], [1]),
        ([1, 2], [], []),
        ([0, 1_000_000_000], [[0, 1, 0, 0], [0, 1, 1_000_000_000, 1_000_000_000], [0, 1, 0, 1_000_000_000]], [1, 1, 2]),
    ] as [([Int], [[Int]], [Int])])
    func examples(fares: [Int], queries: [[Int]], expected: [Int]) {
        #expect(FareWindowCounts.counts(fares: fares, queries: queries) == expected)
    }

    @Test("Random small batches match a scan, with many ties")
    func randomSmall() {
        var random = FareRandom(seed: 62)
        for _ in 0..<300 {
            let n = Int.random(in: 1...25, using: &random)
            let fares = (0..<n).map { _ in Int.random(in: 0...10, using: &random) }
            let queries = (0..<Int.random(in: 0...30, using: &random)).map { _ -> [Int] in
                let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
                let c = Int.random(in: 0...11, using: &random), d = Int.random(in: 0...11, using: &random)
                return [min(a, b), max(a, b), min(c, d), max(c, d)]
            }
            let expected = queries.map { reference(fares, $0) }
            let actual = FareWindowCounts.counts(fares: fares, queries: queries)
            if actual != expected {
                Issue.record("fares \(fares), queries \(queries): expected \(expected), got \(actual)")
                return
            }
        }
    }

    @Test("50,000 questions about 50,000 days")
    func large() {
        var random = FareRandom(seed: 2_026)
        let n = 50_000
        let fares = (0..<n).map { _ in Int.random(in: 0...1_000_000_000, using: &random) }
        let queries = (0..<50_000).map { _ -> [Int] in
            let left = Int.random(in: 0..<(n / 4), using: &random)
            let right = Int.random(in: (n / 2)..<n, using: &random)
            let low = Int.random(in: 0...600_000_000, using: &random)
            return [left, right, low, low + Int.random(in: 0...400_000_000, using: &random)]
        }
        let answers = FareWindowCounts.counts(fares: fares, queries: queries)
        #expect(answers.count == queries.count)
        guard answers.count == queries.count else { return }
        for index in stride(from: 0, to: queries.count, by: 2_499) {
            #expect(answers[index] == reference(fares, queries[index]))
        }
    }

    @Test("Fares equal to the day number: the answer is an overlap of two ranges")
    func planted() {
        let n = 60_000
        let fares = Array(0..<n)
        var random = FareRandom(seed: 5)
        let queries = (0..<60_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            let c = Int.random(in: 0..<n, using: &random), d = Int.random(in: 0..<n, using: &random)
            return [min(a, b), max(a, b), min(c, d), max(c, d)]
        }
        let expected = queries.map { max(0, min($0[1], $0[3]) - max($0[0], $0[2]) + 1) }
        #expect(FareWindowCounts.counts(fares: fares, queries: queries) == expected)
    }
}
