import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LopsidedPairsTests {
    private static func bruteForce(_ numbers: [Int]) -> Int {
        var count = 0
        for i in numbers.indices {
            for j in (i + 1)..<numbers.count where numbers[i] > 2 * numbers[j] {
                count += 1
            }
        }
        return count
    }

    @Test("Counts the lopsided pairs in small arrays", arguments: [
        ([7, 1, 3, 2], 3),
        ([6, 3, 1], 2),
        ([4, 2], 0),
        ([5, 2], 1),
        ([1, 2, 3, 4], 0),
        ([9, 9, 4, 4], 4),
        ([-1, -3], 1),
        ([-5, -2], 0),
        ([0, 0, 0], 0),
        ([1, 0, -1], 3),
        ([8], 0),
        ([], 0),
    ])
    func small(numbers: [Int], expected: Int) {
        #expect(LopsidedPairs.count(in: numbers) == expected)
    }

    @Test("Handles 32-bit extremes without overflow")
    func extremes() {
        let big = Int(Int32.max)
        let small = Int(Int32.min)
        #expect(LopsidedPairs.count(in: [big, big]) == 0)
        #expect(LopsidedPairs.count(in: [small, small]) == 1)
        #expect(LopsidedPairs.count(in: [big, small, 0]) == 2)
    }

    @Test("Matches a brute-force count on hundreds of arrays")
    func matchesBruteForce() {
        var firstFailure: [Int]? = nil
        for seed in 0..<300 {
            let count = seed % 40
            let numbers = (0..<count).map { ($0 * 7_919 + seed * 104_729) % (3 + seed % 41) - (seed % 7) }
            if LopsidedPairs.count(in: numbers) != Self.bruteForce(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that was counted wrongly")
    }

    @Test("100,000 numbers in decreasing order")
    func largeDecreasing() {
        let n = 100_000
        let numbers = Array((0..<n).reversed())
        // For each later value y, the earlier values x with 2y < x ≤ n - 1 each make a pair
        var expected = 0
        for y in 0..<n {
            expected += Swift.max(0, n - 1 - 2 * y)
        }
        #expect(expected == 2_500_000_000)
        #expect(LopsidedPairs.count(in: numbers) == expected)
    }

    @Test("100,000 numbers with no lopsided pairs")
    func largeNone() {
        #expect(LopsidedPairs.count(in: Array(0..<100_000)) == 0)
        #expect(LopsidedPairs.count(in: Array(repeating: 6, count: 100_000)) == 0)
    }
}
