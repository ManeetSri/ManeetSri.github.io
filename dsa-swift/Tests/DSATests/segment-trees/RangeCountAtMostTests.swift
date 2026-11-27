import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct AtMostRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RangeCountAtMostTests {
    /// Counts each range with a loop. Slow, but clearly right.
    private func reference(_ values: [Int], _ queries: [[Int]]) -> [Int] {
        queries.map { query in values[query[0]...query[1]].filter { $0 <= query[2] }.count }
    }

    /// The offline method: answer the queries in increasing order of x, marking each value's position
    /// in DSAKit's FenwickTree once it's at most x. A different technique from a merge-sort tree.
    private func offlineReference(_ values: [Int], _ queries: [[Int]]) -> [Int] {
        let byValue = values.indices.sorted { values[$0] < values[$1] }
        let byX = queries.indices.sorted { queries[$0][2] < queries[$1][2] }
        var marked = FenwickTree(count: values.count)
        var answers = Array(repeating: 0, count: queries.count)
        var next = 0
        for q in byX {
            let query = queries[q]
            while next < byValue.count && values[byValue[next]] <= query[2] {
                marked.add(1, at: byValue[next])
                next += 1
            }
            answers[q] = marked.sum(in: query[0]...query[1])
        }
        return answers
    }

    @Test("The example from the statement")
    func example() {
        let values = [4, 9, 2, 7, 2, 5]
        let queries = [[0, 5, 4], [1, 3, 6], [2, 4, 1], [3, 3, 7], [0, 5, 100]]
        #expect(RangeCountAtMost.answer(values, queries: queries) == [3, 1, 0, 1, 6])
    }

    @Test("Duplicates, negatives and single values")
    func edges() {
        #expect(RangeCountAtMost.answer([5], queries: [[0, 0, 5], [0, 0, 4], [0, 0, 6]]) == [1, 0, 1])
        let values = [-3, -3, 0, -3, 10, -1_000_000_000, 1_000_000_000]
        let queries = [[0, 6, -3], [0, 6, -4], [1, 3, 0], [4, 6, 999_999_999], [0, 6, 1_000_000_000], [5, 5, -1_000_000_000]]
        #expect(RangeCountAtMost.answer(values, queries: queries) == [4, 1, 3, 2, 7, 1])
        #expect(RangeCountAtMost.answer([1, 2, 3], queries: []) == [])
    }

    @Test("Matches counting with a loop on 300 small random arrays")
    func randomSmall() {
        var random = AtMostRandom(seed: 64)
        for _ in 0..<300 {
            let count = Int.random(in: 1...15, using: &random)
            let values = (0..<count).map { _ in Int.random(in: -10...10, using: &random) }
            let queries = (0..<Int.random(in: 1...20, using: &random)).map { _ -> [Int] in
                let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
                return [min(a, b), max(a, b), Int.random(in: -12...12, using: &random)]
            }
            #expect(RangeCountAtMost.answer(values, queries: queries) == reference(values, queries))
        }
    }

    @Test("100,000 values and 100,000 wide queries")
    func large() {
        // Counting each range with a loop would look at about 3 × 10⁹ values
        var random = AtMostRandom(seed: 2_030)
        let count = 100_000
        let values = (0..<count).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let queries = (0..<100_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
            return [min(a, b), max(a, b), Int.random(in: -1_000_000_000...1_000_000_000, using: &random)]
        }
        #expect(RangeCountAtMost.answer(values, queries: queries) == offlineReference(values, queries))
    }
}
