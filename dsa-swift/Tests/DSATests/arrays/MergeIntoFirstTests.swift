import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MergeIntoFirstTests {
    // Pads `values` with spare slots holding `filler`, merges, and returns the result
    private func merged(_ values: [Int], _ second: [Int], filler: Int = 0) -> [Int] {
        var first = values + Array(repeating: filler, count: second.count)
        MergeIntoFirst.merge(&first, used: values.count, with: second)
        return first
    }

    @Test("Merges two sorted arrays", arguments: [
        ([1, 4, 7], [2, 3, 9], [1, 2, 3, 4, 7, 9]),
        ([2, 5, 6], [1, 8], [1, 2, 5, 6, 8]),
        ([10, 20], [1, 2, 3], [1, 2, 3, 10, 20]),
        ([1, 2, 3], [7, 8], [1, 2, 3, 7, 8]),
        ([-5, 0, 5], [-6, -1, 4, 6], [-6, -5, -1, 0, 4, 5, 6]),
    ])
    func merges(values: [Int], second: [Int], expected: [Int]) {
        #expect(merged(values, second) == expected)
    }

    @Test("Handles equal values", arguments: [
        ([1, 3, 3], [3, 3, 4], [1, 3, 3, 3, 3, 4]),
        ([2, 2], [2, 2], [2, 2, 2, 2]),
    ])
    func equalValues(values: [Int], second: [Int], expected: [Int]) {
        #expect(merged(values, second) == expected)
    }

    @Test("Either side can be empty")
    func emptySides() {
        #expect(merged([1, 2, 3], []) == [1, 2, 3])
        #expect(merged([], [4, 5]) == [4, 5])
        #expect(merged([], []) == [])
    }

    @Test("The spare slots' contents don't matter")
    func spareSlotsIgnored() {
        #expect(merged([1, 5], [2, 3], filler: 99) == [1, 2, 3, 5])
        #expect(merged([1, 5], [2, 3], filler: -99) == [1, 2, 3, 5])
    }

    @Test("Matches sorting on many small cases")
    func matchesSorting() {
        var firstMismatch: [[Int]]? = nil
        for seed in 0..<300 {
            let values = (0..<(seed % 6)).map { ($0 * 5 + seed) % 9 - 4 }.sorted()
            let second = (0..<(seed % 5)).map { ($0 * 3 + seed * 2) % 9 - 4 }.sorted()
            if merged(values, second, filler: seed) != (values + second).sorted() {
                firstMismatch = firstMismatch ?? [values, second]
            }
        }
        #expect(firstMismatch == nil, "the first pair of arrays that merged wrongly")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let evens = Array(stride(from: 0, to: 100_000, by: 2))
        let odds = Array(stride(from: 1, to: 100_000, by: 2))
        #expect(merged(evens, odds) == Array(0..<100_000))
    }
}
