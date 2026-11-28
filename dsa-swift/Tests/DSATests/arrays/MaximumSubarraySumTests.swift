import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MaximumSubarraySumTests {
    @Test("Finds the best run", arguments: [
        ([-2, 1, -3, 4, -1, 2, 1, -5, 4], 6),
        ([3, -1, 4], 6),
        ([5, -9, 6], 6),
        ([2, 3, 4], 9),
        ([4, -1, -1, 4], 6),
        ([1, -2, 3, -2, 5, -10, 4], 6),
        ([-1, 3, -1, 3, -10, 5], 5),
        ([0, 0, 0], 0),
    ])
    func best(numbers: [Int], expected: Int) {
        #expect(MaximumSubarraySum.bestSum(in: numbers) == expected)
    }

    @Test("All-negative arrays pick the largest element", arguments: [
        ([-3, -1, -2], -1),
        ([-8], -8),
        ([-5, -5, -5], -5),
        ([-1_000_000_000, -7, -1_000_000_000], -7),
    ])
    func allNegative(numbers: [Int], expected: Int) {
        #expect(MaximumSubarraySum.bestSum(in: numbers) == expected)
    }

    @Test("A single element", arguments: [[9], [0], [-4]])
    func single(numbers: [Int]) {
        #expect(MaximumSubarraySum.bestSum(in: numbers) == numbers[0])
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<400 {
            let numbers = (0...(seed % 9)).map { ($0 * 7 + seed * 3) % 11 - 6 }
            var expected = Int.min
            for start in numbers.indices {
                var sum = 0
                for end in start..<numbers.count {
                    sum += numbers[end]
                    expected = max(expected, sum)
                }
            }
            if MaximumSubarraySum.bestSum(in: numbers) != expected {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        // Alternating 3 and -2: the best run is everything except the final -2
        let wave = (0..<100_000).map { $0 % 2 == 0 ? 3 : -2 }
        #expect(MaximumSubarraySum.bestSum(in: wave) == 50_002)
        let negatives = (0..<100_000).map { -1 - ($0 % 1_000) }
        #expect(MaximumSubarraySum.bestSum(in: negatives) == -1)
        let big = Array(repeating: 1_000_000_000, count: 100_000)
        #expect(MaximumSubarraySum.bestSum(in: big) == 100_000_000_000_000)
    }
}
