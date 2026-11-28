import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LongestConsecutiveRunTests {
    @Test("Finds the longest run", arguments: [
        ([12, 4, 200, 1, 3, 2], 4),
        ([7, 7, 8, 9, 9, 20], 3),
        ([0, -1, -3, -2, 5], 4),
        ([10, 30, 20], 1),
        ([5], 1),
        ([1, 2, 0, 1], 3),
        ([9, 1, 4, 7, 3, -1, 0, 5, 8, -1, 6], 7),
    ])
    func finds(numbers: [Int], expected: Int) {
        #expect(LongestConsecutiveRun.length(in: numbers) == expected)
    }

    @Test("An empty array has no run")
    func empty() {
        #expect(LongestConsecutiveRun.length(in: []) == 0)
    }

    @Test("Handles the extremes of the allowed values")
    func extremes() {
        #expect(LongestConsecutiveRun.length(in: [1_000_000_000, -1_000_000_000, 999_999_999]) == 2)
    }

    @Test("Matches sorting on many small arrays")
    func matchesSorting() {
        func bySorting(_ numbers: [Int]) -> Int {
            let sorted = Array(Set(numbers)).sorted()
            var best = sorted.isEmpty ? 0 : 1
            var current = 1
            for index in sorted.indices.dropFirst() {
                current = sorted[index] == sorted[index - 1] + 1 ? current + 1 : 1
                best = max(best, current)
            }
            return best
        }
        var mismatches = 0
        for seed in 0..<400 {
            let numbers = (0..<(seed % 12)).map { ($0 * 5 + seed * 3) % 17 - 8 }
            if LongestConsecutiveRun.length(in: numbers) != bySorting(numbers) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast on 100,000 shuffled numbers")
    func large() {
        // 0 to 99,999 in a scrambled order: 7919 and 100,000 share no factor, so this is a permutation
        let scrambled = (0..<100_000).map { ($0 * 7_919) % 100_000 }
        #expect(LongestConsecutiveRun.length(in: scrambled) == 100_000)
        // Every second number: the longest run is 1
        #expect(LongestConsecutiveRun.length(in: scrambled.map { $0 * 2 }) == 1)
    }

    @Test("Stays fast when the start of a long run is repeated many times")
    func repeatedStart() {
        let numbers = Array(repeating: 0, count: 20_000) + Array(0..<20_000)
        #expect(LongestConsecutiveRun.length(in: numbers) == 20_000)
    }
}
