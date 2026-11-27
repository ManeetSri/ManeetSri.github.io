import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DisorderRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ArrivalDisorderTests {
    /// Compares each new value with every earlier one. O(n²), but clearly right.
    private func reference(_ values: [Int]) -> [Int] {
        var total = 0
        return values.indices.map { j in
            total += values[..<j].filter { $0 > values[j] }.count
            return total
        }
    }

    /// A fast reference built on DSAKit's FenwickTree, which has its own tests: counts by rank, found
    /// through a sorted array of the distinct values.
    private func fastReference(_ values: [Int]) -> [Int] {
        let distinct = Array(Set(values)).sorted()
        var counts = FenwickTree(count: distinct.count)
        var total = 0
        return values.enumerated().map { index, value in
            var low = 0, high = distinct.count
            while low < high {
                let mid = (low + high) / 2
                if distinct[mid] <= value { low = mid + 1 } else { high = mid }
            }
            total += index - counts.prefixSum(upTo: low)       // low = how many distinct values are <= value
            counts.add(1, at: low - 1)
            return total
        }
    }

    @Test("Examples and small cases", arguments: [
        ([3, 1, 2, 5, 4, 1], [0, 1, 2, 2, 3, 7]),
        ([], []),
        ([42], [0]),
        ([1, 2, 3, 4], [0, 0, 0, 0]),
        ([4, 3, 2, 1], [0, 1, 3, 6]),
        ([2, 2, 2], [0, 0, 0]),
        ([5, -5, 5, -5], [0, 1, 1, 3]),
        ([Int.max, Int.min, 0], [0, 1, 2]),
    ] as [([Int], [Int])])
    func examples(values: [Int], expected: [Int]) {
        #expect(ArrivalDisorder.inversionCounts(values) == expected)
    }

    @Test("Matches comparing every pair on 400 small random arrays")
    func randomSmall() {
        var random = DisorderRandom(seed: 65)
        for _ in 0..<400 {
            let values = (0..<Int.random(in: 0...15, using: &random)).map { _ in Int.random(in: -5...5, using: &random) }
            #expect(ArrivalDisorder.inversionCounts(values) == reference(values))
        }
    }

    @Test("100,000 values in reverse order: every pair is an inversion")
    func reversed() throws {
        let n = 100_000
        let result = ArrivalDisorder.inversionCounts(Array((0..<n).reversed()))
        try #require(result.count == n)
        #expect(result[1] == 1)
        #expect(result[999] == 999 * 1_000 / 2)
        #expect(result.last == (n - 1) * n / 2)                 // nearly 5 × 10⁹: needs 64-bit Int
    }

    @Test("100,000 random values")
    func large() {
        // Comparing every pair would be 5 × 10⁹ comparisons
        var random = DisorderRandom(seed: 2_031)
        let values = (0..<100_000).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        #expect(ArrivalDisorder.inversionCounts(values) == fastReference(values))
        let fewDistinct = (0..<100_000).map { _ in Int.random(in: 0..<50, using: &random) }
        #expect(ArrivalDisorder.inversionCounts(fewDistinct) == fastReference(fewDistinct))
    }
}
