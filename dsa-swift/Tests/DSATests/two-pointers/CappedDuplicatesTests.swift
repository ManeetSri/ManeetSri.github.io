import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CappedDuplicatesTests {
    /// Runs the function and returns the kept part of the array.
    private static func kept(_ numbers: [Int], limit: Int) -> [Int] {
        var copy = numbers
        let k = CappedDuplicates.compact(&copy, keeping: limit)
        return Array(copy.prefix(max(0, k)))
    }

    private static func expectedKept(_ numbers: [Int], limit: Int) -> [Int] {
        var result: [Int] = []
        var counts: [Int: Int] = [:]
        for value in numbers {
            counts[value, default: 0] += 1
            if counts[value]! <= limit {
                result.append(value)
            }
        }
        return result
    }

    @Test("Keeps at most two of each value", arguments: [
        ([1, 1, 1, 2, 2, 3], [1, 1, 2, 2, 3]),
        ([4, 4, 4, 4, 5, 6, 6, 6], [4, 4, 5, 6, 6]),
        ([-3, -3, -3, 0, 8, 8], [-3, -3, 0, 8, 8]),
        ([1, 2, 3], [1, 2, 3]),
        ([9, 9], [9, 9]),
        ([5], [5]),
        ([], []),
    ])
    func keepTwo(numbers: [Int], expected: [Int]) {
        #expect(Self.kept(numbers, limit: 2) == expected)
    }

    @Test("Works for other limits", arguments: [
        ([1, 1, 2, 3, 3, 3], 1, [1, 2, 3]),
        ([7, 7, 7, 7, 7], 3, [7, 7, 7]),
        ([1, 2, 2], 5, [1, 2, 2]),
        ([2, 2, 2, 2, 3, 3, 3, 3], 3, [2, 2, 2, 3, 3, 3]),
    ])
    func otherLimits(numbers: [Int], limit: Int, expected: [Int]) {
        #expect(Self.kept(numbers, limit: limit) == expected)
    }

    @Test("Returns the number of elements kept")
    func returnsCount() {
        var numbers = [0, 0, 0, 1, 1, 1, 1, 2]
        #expect(CappedDuplicates.compact(&numbers, keeping: 2) == 5)
        #expect(Array(numbers.prefix(5)) == [0, 0, 1, 1, 2])
    }

    @Test("Matches counting copies on many small sorted arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let numbers = (0..<(seed % 12)).map { ($0 * 3 + seed) % 5 - 2 }.sorted()
            let limit = seed % 4 + 1
            if Self.kept(numbers, limit: limit) != Self.expectedKept(numbers, limit: limit) {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the kept part differs from the expected one")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        // Each value from 0 to 19,999 appears five times
        let numbers = (0..<100_000).map { $0 / 5 }
        let expected = (0..<40_000).map { $0 / 2 }
        #expect(Self.kept(numbers, limit: 2) == expected)
        #expect(Self.kept(numbers, limit: 5) == numbers)
    }
}
