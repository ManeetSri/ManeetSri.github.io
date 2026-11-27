import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TopFrequentValuesTests {
    @Test("Small cases", arguments: [
        ([4, 1, 4, 2, 4, 1, 3], 2, [4, 1]),
        ([4, 1, 4, 2, 4, 1, 3], 4, [4, 1, 2, 3]),
        ([7, 7, 8, 8, 9], 2, [7, 8]),
        ([7, 7, 8, 8, 9], 3, [7, 8, 9]),
        ([-2, -2, 5, 5, 0], 1, [-2]),
        ([3], 1, [3]),
        ([1, 2, 3], 5, [1, 2, 3]),
        ([6, 6, 6], 2, [6]),
        ([Int](), 3, [Int]()),
    ])
    func small(values: [Int], k: Int, expected: [Int]) {
        #expect(TopFrequentValues.mostFrequent(values, k: k) == expected)
    }

    @Test("Agrees with sorting the counts on hundreds of inputs")
    func matchesSorting() {
        var mismatches = 0
        for seed in 1...200 {
            let values = (0..<(seed % 60)).map { ($0 * $0 * 7 + seed * 13) % (2 + seed % 15) - 3 }
            let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
            let ranked = counts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }.map(\.key)
            for k in 1...4 where TopFrequentValues.mostFrequent(values, k: k) != Array(ranked.prefix(k)) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("200,000 values with about 20,000 distinct ones")
    func large() {
        let values = (0..<200_000).map { ($0 * 7_919 % 10_007) * ($0 % 13) % 20_011 }
        #expect(TopFrequentValues.mostFrequent(values, k: 10) == [0, 5_040, 2_088, 2_520, 3_360, 3_408, 6_288, 7_128, 7_368, 9_540])
        #expect(TopFrequentValues.mostFrequent(values, k: 1) == [0])
        #expect(TopFrequentValues.mostFrequent(values, k: 30_000).count == 19_976)
    }

    @Test("150,000 distinct values, nearly all seen once")
    func largeTies() {
        let values = Array((0..<150_000).reversed()) + [77, 77, 1_234]
        #expect(TopFrequentValues.mostFrequent(values, k: 4) == [77, 1_234, 0, 1])
    }
}
