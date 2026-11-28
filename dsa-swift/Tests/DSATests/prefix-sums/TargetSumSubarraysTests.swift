import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TargetSumSubarraysTests {
    private static func slowCount(_ numbers: [Int], _ target: Int) -> Int {
        var count = 0
        for start in numbers.indices {
            var sum = 0
            for end in start..<numbers.count {
                sum += numbers[end]
                if sum == target { count += 1 }
            }
        }
        return count
    }

    private static func slowLongest(_ numbers: [Int], _ target: Int) -> Int {
        var best = 0
        for start in numbers.indices {
            var sum = 0
            for end in start..<numbers.count {
                sum += numbers[end]
                if sum == target { best = max(best, end - start + 1) }
            }
        }
        return best
    }

    @Test("Counts subarrays with the target sum", arguments: [
        ([1, 2, -1, 3, -2, 2], 3, 4),
        ([1, -1, 1, -1], 0, 4),
        ([4, -3, 2], 3, 1),
        ([5], 5, 1),
        ([5], 4, 0),
        ([], 0, 0),
        ([0, 0, 0], 0, 6),
        ([2, 2, 2], 4, 2),
        ([-1, -1, 1], -1, 3),
    ])
    func counts(numbers: [Int], target: Int, expected: Int) {
        #expect(TargetSumSubarrays.count(in: numbers, summingTo: target) == expected)
    }

    @Test("Finds the longest subarray with the target sum", arguments: [
        ([1, -1, 5, -2, 3], 3, 4),
        ([2, 2, 2], 5, 0),
        ([1, 2, -1, 3, -2, 2], 3, 5),
        ([3, -3, 1, 2], 3, 4),
        ([0, 0, 0], 0, 3),
        ([], 0, 0),
        ([7], 7, 1),
        ([-2, -1, 2, 1], 1, 2),
    ])
    func longest(numbers: [Int], target: Int, expected: Int) {
        #expect(TargetSumSubarrays.longest(in: numbers, summingTo: target) == expected)
    }

    @Test("Matches a brute force on many small arrays with negatives and zeros")
    func matchesBruteForce() {
        var countMismatch: [Int]? = nil
        var longestMismatch: [Int]? = nil
        for seed in 0..<300 {
            let numbers = (0..<(seed % 11)).map { ($0 * 13 + seed * 7) % 7 - 3 }
            let target = seed % 5 - 2
            if TargetSumSubarrays.count(in: numbers, summingTo: target) != Self.slowCount(numbers, target) {
                countMismatch = countMismatch ?? numbers
            }
            if TargetSumSubarrays.longest(in: numbers, summingTo: target) != Self.slowLongest(numbers, target) {
                longestMismatch = longestMismatch ?? numbers
            }
        }
        #expect(countMismatch == nil, "the first array where count differs from the brute force")
        #expect(longestMismatch == nil, "the first array where longest differs from the brute force")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let n = 100_000
        let zeros = Array(repeating: 0, count: n)
        #expect(TargetSumSubarrays.count(in: zeros, summingTo: 0) == n * (n + 1) / 2)
        #expect(TargetSumSubarrays.longest(in: zeros, summingTo: 0) == n)

        let alternating = (0..<n).map { $0 % 2 == 0 ? 1 : -1 }
        #expect(TargetSumSubarrays.count(in: alternating, summingTo: 0) == 2_500_000_000)
        #expect(TargetSumSubarrays.longest(in: alternating, summingTo: 0) == n)

        let ones = Array(repeating: 1, count: n)
        #expect(TargetSumSubarrays.count(in: ones, summingTo: 500) == n - 499)
        #expect(TargetSumSubarrays.longest(in: ones, summingTo: 500) == 500)
    }
}
