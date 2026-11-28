import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SmallestGapTests {
    @Test("Finds the closest pair", arguments: [
        ([9, 2, 14, 5], 3),
        ([40, 10, 24, 22], 2),
        ([-7, 3], 10),
        ([1, 2], 1),
        ([100, 1, 50, 52, 75], 2),
        ([-10, -4, -20, -5], 1),
    ])
    func closest(numbers: [Int], expected: Int) {
        #expect(SmallestGap.smallestGap(in: numbers) == expected)
    }

    @Test("Repeated values have a gap of 0")
    func duplicates() {
        #expect(SmallestGap.smallestGap(in: [4, 7, 4]) == 0)
        #expect(SmallestGap.smallestGap(in: [8, 8]) == 0)
    }

    @Test("Handles the widest possible gap")
    func extremes() {
        #expect(SmallestGap.smallestGap(in: [-1_000_000_000, 1_000_000_000]) == 2_000_000_000)
    }

    @Test("Sorted and reversed input")
    func ordered() {
        #expect(SmallestGap.smallestGap(in: [1, 4, 9, 16, 25]) == 3)
        #expect(SmallestGap.smallestGap(in: [25, 16, 9, 4, 1]) == 3)
    }

    @Test("Matches the brute force on 2,000 numbers")
    func large() {
        let numbers = (0..<2_000).map { ($0 * 7_919 + 13) % 1_000_003 - 500_000 }
        var expected = Int.max
        for i in 0..<numbers.count {
            for j in (i + 1)..<numbers.count {
                expected = min(expected, abs(numbers[i] - numbers[j]))
            }
        }
        #expect(SmallestGap.smallestGap(in: numbers) == expected)
    }
}
