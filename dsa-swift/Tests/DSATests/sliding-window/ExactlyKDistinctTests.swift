import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ExactlyKDistinctTests {
    @Test("Counts subarrays with exactly k distinct values", arguments: [
        ([4, 4, 7, 4, 9], 2, 6),
        ([5, 5, 5], 1, 6),
        ([1, 2, 3], 3, 1),
        ([1, 2, 3], 4, 0),
        ([3, 1, 3, 2, 1], 2, 5),
        ([3, 1, 3, 2, 1], 3, 5),
        ([7], 1, 1),
        ([1, 2, 1, 3, 4], 3, 3),
        ([-1, 1_000_000_000, -1], 2, 3),
    ])
    func examples(values: [Int], k: Int, expected: Int) {
        #expect(ExactlyKDistinct.count(values, k: k) == expected)
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let values = (0..<(seed % 11 + 1)).map { ($0 * $0 + seed * 3) % 4 }
            let k = seed % 4 + 1
            var expected = 0
            for start in values.indices {
                var seen = Set<Int>()
                for end in start..<values.count {
                    seen.insert(values[end])
                    if seen.count == k { expected += 1 }
                }
            }
            if ExactlyKDistinct.count(values, k: k) != expected {
                firstMismatch = firstMismatch ?? values
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 values")
    func large() {
        // 1, 2, 3, 1, 2, 3, ...: windows of length 1 have 1 distinct value, length 2 have 2, longer have 3
        let n = 100_000
        let cycling = (0..<n).map { $0 % 3 + 1 }
        #expect(ExactlyKDistinct.count(cycling, k: 1) == n)
        #expect(ExactlyKDistinct.count(cycling, k: 2) == n - 1)
        #expect(ExactlyKDistinct.count(cycling, k: 3) == (n - 1) * (n - 2) / 2)

        // Every subarray of identical values has exactly one distinct value
        let same = [Int](repeating: 42, count: n)
        #expect(ExactlyKDistinct.count(same, k: 1) == n * (n + 1) / 2)
    }
}
