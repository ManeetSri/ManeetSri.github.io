import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SortedSquaresTests {
    @Test("Squares stay sorted", arguments: [
        ([-7, -3, -1, 2, 4, 6], [1, 4, 9, 16, 36, 49]),
        ([-5, -4, -2], [4, 16, 25]),
        ([0, 3, 8], [0, 9, 64]),
        ([-2, -2, 2], [4, 4, 4]),
        ([-3, 0, 0, 1], [0, 0, 1, 9]),
        ([-10_000, 10_000], [100_000_000, 100_000_000]),
        ([-1], [1]),
        ([], []),
    ])
    func squares(sorted: [Int], expected: [Int]) {
        #expect(SortedSquares.squares(of: sorted) == expected)
    }

    @Test("Matches square-then-sort on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<300 {
            let sorted = (0..<(seed % 9)).map { ($0 * 5 + seed * 3) % 13 - 6 }.sorted()
            if SortedSquares.squares(of: sorted) != sorted.map({ $0 * $0 }).sorted() {
                firstMismatch = firstMismatch ?? sorted
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from square-then-sort")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let sorted = Array(-60_000..<40_000)
        #expect(SortedSquares.squares(of: sorted) == sorted.map { $0 * $0 }.sorted())
        let negatives = Array(-100_000..<0)
        #expect(SortedSquares.squares(of: negatives) == (1...100_000).map { $0 * $0 })
    }
}
