import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SortFromScratchTests {
    /// Deterministic pseudo-random values, the same every run.
    private static func scrambled(count: Int, below limit: Int, seed: UInt64) -> [Int] {
        var state = seed
        return (0..<count).map { _ in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Sorts small arrays", arguments: [
        ([5, 2, 9, 1, 5, 6], [1, 2, 5, 5, 6, 9]),
        ([38, 27, 43, 3, 9, 82, 10], [3, 9, 10, 27, 38, 43, 82]),
        ([3, -1, 0, -7, 3], [-7, -1, 0, 3, 3]),
        ([1, 2, 3, 4], [1, 2, 3, 4]),
        ([4, 3, 2, 1], [1, 2, 3, 4]),
        ([2, 2, 2], [2, 2, 2]),
        ([2, 1], [1, 2]),
        ([7], [7]),
        ([], []),
    ])
    func small(numbers: [Int], expected: [Int]) {
        #expect(SortFromScratch.sorted(numbers) == expected)
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        #expect(SortFromScratch.sorted([Int.max, 0, Int.min, -1]) == [Int.min, -1, 0, Int.max])
    }

    @Test("Matches sorted() on hundreds of arrays", arguments: [3, 1_000_000])
    func matchesStandardLibrary(limit: Int) {
        var firstFailure: [Int]? = nil
        for count in 0...200 {
            let numbers = Self.scrambled(count: count, below: limit, seed: UInt64(count + limit))
            if SortFromScratch.sorted(numbers) != numbers.sorted() {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that came out wrong")
    }

    @Test("100,000 numbers already in order, and in reverse")
    func largeOrdered() {
        let ascending = Array(0..<100_000)
        #expect(SortFromScratch.sorted(ascending) == ascending)
        #expect(SortFromScratch.sorted(Array(ascending.reversed())) == ascending)
    }

    @Test("100,000 equal numbers, and 100,000 of two values")
    func largeDuplicates() {
        let same = Array(repeating: 7, count: 100_000)
        #expect(SortFromScratch.sorted(same) == same)
        let alternating = (0..<100_000).map { $0 % 2 }
        #expect(SortFromScratch.sorted(alternating) == Array(repeating: 0, count: 50_000) + Array(repeating: 1, count: 50_000))
    }

    @Test("100,000 scrambled numbers")
    func largeScrambled() {
        let numbers = Self.scrambled(count: 100_000, below: 1_000_000_000, seed: 2024)
        #expect(SortFromScratch.sorted(numbers) == numbers.sorted())
    }
}
