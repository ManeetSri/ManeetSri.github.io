import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InversionCountTests {
    private static func bruteForce(_ numbers: [Int]) -> Int {
        var count = 0
        for i in numbers.indices {
            for j in (i + 1)..<numbers.count where numbers[i] > numbers[j] {
                count += 1
            }
        }
        return count
    }

    @Test("Counts the inversions in small arrays", arguments: [
        ([4, 1, 3, 2], 4),
        ([2, 4, 1, 3, 5], 3),
        ([1, 2, 3, 4], 0),
        ([5, 4, 3, 2, 1], 10),
        ([3, 3, 1], 2),
        ([1, 1, 1], 0),
        ([2, 1, 2, 1], 3),
        ([-2, 5, -7, 0], 3),
        ([9, 1], 1),
        ([7], 0),
        ([], 0),
    ])
    func small(numbers: [Int], expected: Int) {
        #expect(InversionCount.count(in: numbers) == expected)
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        #expect(InversionCount.count(in: [Int.max, Int.min, 0]) == 2)
    }

    @Test("Matches a brute-force count on hundreds of arrays")
    func matchesBruteForce() {
        var firstFailure: [Int]? = nil
        for seed in 0..<300 {
            let count = seed % 40
            let numbers = (0..<count).map { ($0 * 7_919 + seed * 104_729) % (2 + seed % 23) }
            if InversionCount.count(in: numbers) != Self.bruteForce(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that was counted wrongly")
    }

    @Test("100,000 numbers in reverse: every pair is an inversion")
    func largeReversed() {
        let numbers = Array((0..<100_000).reversed())
        #expect(InversionCount.count(in: numbers) == 4_999_950_000)
    }

    @Test("100,000 numbers with no inversions")
    func largeNone() {
        #expect(InversionCount.count(in: Array(0..<100_000)) == 0)
        #expect(InversionCount.count(in: Array(repeating: 3, count: 100_000)) == 0)
    }

    @Test("Two sorted halves swapped: every pair across them is an inversion")
    func largeHalves() {
        let numbers = Array(50_000..<100_000) + Array(0..<50_000)
        #expect(InversionCount.count(in: numbers) == 2_500_000_000)
    }
}
