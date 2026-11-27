import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoSumIndexesTests {
    @Test("Finds the pair", arguments: [
        ([8, 3, 11, 5], 16, [2, 3]),
        ([4, 9, 2, 7], 9, [2, 3]),
        ([5, 5], 10, [0, 1]),
        ([-4, 10, 6, -2], 4, [2, 3]),
        ([0, 7, 0], 0, [0, 2]),
        ([1, 2, 3, 4, 5], 9, [3, 4]),
    ])
    func findsPair(numbers: [Int], target: Int, expected: [Int]) {
        #expect(TwoSumIndexes.indexes(in: numbers, summingTo: target) == expected)
    }

    @Test("Prefers the pair that finishes first, then the earliest partner")
    func tieBreaking() {
        // 1 + 5 finishes at index 2; 3 + 3 would finish at index 3
        #expect(TwoSumIndexes.indexes(in: [1, 3, 5, 3], summingTo: 6) == [0, 2])
        // Two copies of 2 before the 4: the first one wins
        #expect(TwoSumIndexes.indexes(in: [2, 2, 4], summingTo: 6) == [0, 2])
        #expect(TwoSumIndexes.indexes(in: [3, 3, 3], summingTo: 6) == [0, 1])
    }

    @Test("Returns nil when no pair works", arguments: [
        ([Int](), 5),
        ([5], 10),
        ([1, 2, 3], 100),
        ([3, 4], 6),
    ])
    func noPair(numbers: [Int], target: Int) {
        #expect(TwoSumIndexes.indexes(in: numbers, summingTo: target) == nil)
    }

    @Test("Handles the extremes of the allowed values")
    func extremes() {
        #expect(TwoSumIndexes.indexes(in: [1_000_000_000, 7, 1_000_000_000], summingTo: 2_000_000_000) == [0, 2])
        #expect(TwoSumIndexes.indexes(in: [-1_000_000_000, 0, -1_000_000_000], summingTo: -2_000_000_000) == [0, 2])
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        func bruteForce(_ numbers: [Int], _ target: Int) -> [Int]? {
            for j in numbers.indices {
                for i in 0..<j where numbers[i] + numbers[j] == target {
                    return [i, j]
                }
            }
            return nil
        }
        var firstMismatch: [Int]? = nil
        for seed in 0..<500 {
            let numbers = (0..<(seed % 9)).map { ($0 * 7 + seed * 5) % 11 - 5 }
            let target = seed % 13 - 6
            if TwoSumIndexes.indexes(in: numbers, summingTo: target) != bruteForce(numbers, target) {
                firstMismatch = firstMismatch ?? numbers + [target]
            }
        }
        #expect(firstMismatch == nil, "the numbers, then the target, of the first case that differs")
    }

    @Test("Stays fast on 100,000 numbers with the pair at the very end")
    func large() {
        var numbers = Array(stride(from: 2, through: 199_998, by: 2))   // 99,999 even numbers
        numbers.append(-1)
        // Only 2 + (-1) makes 1, and -1 is the last element
        #expect(TwoSumIndexes.indexes(in: numbers, summingTo: 1) == [0, 99_999])
        // Even + even is even, and -1 would need a 3: nothing makes 2
        #expect(TwoSumIndexes.indexes(in: numbers, summingTo: 2) == nil)
    }
}
