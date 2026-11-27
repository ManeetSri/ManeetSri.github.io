import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BinomialRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BinomialQueryBankTests {
    private let mod = 1_000_000_007

    private func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1, square = base % mod, e = exponent
        while e > 0 {
            if e & 1 == 1 { result = result * square % mod }
            square = square * square % mod
            e >>= 1
        }
        return result
    }

    /// C(n, k) = n(n − 1)…(n − k + 1) / k!, with one Fermat inverse at the end. O(k) per query.
    private func slowChoose(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        let k = min(k, n - k)
        var top = 1, bottom = 1
        for i in 0..<k {
            top = top * (n - i) % mod
            bottom = bottom * (i + 1) % mod
        }
        return top * power(bottom, mod - 2) % mod
    }

    @Test("Examples")
    func examples() {
        #expect(BinomialQueryBank.answers([[5, 2], [10, 3], [7, 9], [0, 0], [7, -1], [1000, 500]])
                == [10, 120, 0, 1, 0, 159_835_829])
        #expect(BinomialQueryBank.answers([[1, 1], [1, 0], [2, 1], [4, 2]]) == [1, 1, 2, 6])
        #expect(BinomialQueryBank.answers([]) == [])
        #expect(BinomialQueryBank.answers([[0, 1], [0, -1], [3, 4]]) == [0, 0, 0])
    }

    @Test("Matches Pascal's triangle for every n up to 300")
    func pascal() {
        var queries: [[Int]] = []
        var expected: [Int] = []
        var row = [1]
        for n in 0...300 {
            for k in -2...(n + 2) {
                queries.append([n, k])
                expected.append(k >= 0 && k <= n ? row[k] : 0)
            }
            row = [1] + (1..<row.count).map { (row[$0 - 1] + row[$0]) % mod } + [1]
        }
        #expect(BinomialQueryBank.answers(queries) == expected)
    }

    @Test("Known values for n up to a million")
    func knownValues() {
        #expect(BinomialQueryBank.answers([[1_000_000, 500_000], [999_999, 123_456], [1_000_000, 1], [1_000_000, 1_000_000]])
                == [996_692_777, 984_332_785, 1_000_000, 1])
    }

    @Test("A hundred thousand queries with n up to a million")
    func manyQueries() {
        var random = BinomialRandom(seed: 58)
        let queries = (0..<100_000).map { _ -> [Int] in
            let n = Int.random(in: 0...1_000_000, using: &random)
            return [n, Int.random(in: -5...(n + 5), using: &random)]
        }
        let answers = BinomialQueryBank.answers(queries)
        #expect(answers.count == queries.count)
        guard answers.count == queries.count else { return }
        // Check a sample against the slow formula, choosing queries whose smaller side is cheap
        var checked = 0
        for (query, answer) in zip(queries, answers) where checked < 40 {
            let (n, k) = (query[0], query[1])
            if min(k, n - k) <= 20_000 {
                #expect(answer == slowChoose(n, k), "C(\(n), \(k))")
                checked += 1
            }
        }
        // And a few with large k on both sides
        for (n, k) in [(1_000_000, 333_333), (987_654, 400_000), (500_000, 250_000)] {
            #expect(BinomialQueryBank.answers([[n, k], [n, n - k]]) == [slowChoose(n, k), slowChoose(n, k)])
        }
    }
}
