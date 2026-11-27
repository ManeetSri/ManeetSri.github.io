import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UnrotateSortedTests {
    @Test("Restores sorted order", arguments: [
        ([4, 5, 6, 1, 2, 3], [1, 2, 3, 4, 5, 6]),
        ([9, 2, 4, 7], [2, 4, 7, 9]),
        ([3, 5, 8, 11, 1], [1, 3, 5, 8, 11]),
        ([2, 1], [1, 2]),
        ([10, 20, 30], [10, 20, 30]),
        ([-3, 0, -9, -5], [-9, -5, -3, 0]),
    ])
    func restores(numbers: [Int], expected: [Int]) {
        var values = numbers
        UnrotateSorted.unrotate(&values)
        #expect(values == expected)
    }

    @Test("Handles repeated values", arguments: [
        ([3, 3, 1, 2, 2], [1, 2, 2, 3, 3]),
        ([2, 2, 2, 1], [1, 2, 2, 2]),
        ([5, 1, 1, 1], [1, 1, 1, 5]),
        ([4, 4, 4], [4, 4, 4]),
        ([1, 1, 2, 1], [1, 1, 1, 2]),
    ])
    func repeats(numbers: [Int], expected: [Int]) {
        var values = numbers
        UnrotateSorted.unrotate(&values)
        #expect(values == expected)
    }

    @Test("Leaves tiny arrays alone", arguments: [[Int](), [7]])
    func tiny(numbers: [Int]) {
        var values = numbers
        UnrotateSorted.unrotate(&values)
        #expect(values == numbers)
    }

    @Test("Undoes every rotation of a small array")
    func everyRotation() {
        let sorted = [1, 2, 2, 4, 6, 6, 9]
        var firstFailure: Int? = nil
        for steps in 0..<sorted.count {
            var values = Array(sorted[steps...] + sorted[..<steps])
            UnrotateSorted.unrotate(&values)
            if values != sorted {
                firstFailure = firstFailure ?? steps
            }
        }
        #expect(firstFailure == nil, "the first rotation, in steps left, that wasn't undone")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let sorted = Array(0..<100_000)
        var values = Array(sorted[37_000...] + sorted[..<37_000])
        UnrotateSorted.unrotate(&values)
        #expect(values == sorted)
    }
}
