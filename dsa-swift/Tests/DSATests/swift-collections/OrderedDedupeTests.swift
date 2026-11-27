import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct OrderedDedupeTests {
    @Test("Keeps the first copy of each value, in order", arguments: [
        ([3, 1, 3, 2, 1], [3, 1, 2]),
        ([5, 5, 5, 5], [5]),
        ([1, 2, 3], [1, 2, 3]),
        ([4, 3, 2, 1, 1, 2, 3, 4], [4, 3, 2, 1]),
        ([0, -1, 0, -1, 2], [0, -1, 2]),
    ])
    func dedupes(numbers: [Int], expected: [Int]) {
        #expect(OrderedDedupe.dedupe(numbers) == expected)
    }

    @Test("Handles empty and single-element arrays")
    func tiny() {
        #expect(OrderedDedupe.dedupe([]) == [])
        #expect(OrderedDedupe.dedupe([42]) == [42])
    }

    @Test("Does not sort the result")
    func keepsOrder() {
        #expect(OrderedDedupe.dedupe([9, 2, 9, 7, 2]) == [9, 2, 7])
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = (0..<100_000).map { $0 % 1_000 }
        #expect(OrderedDedupe.dedupe(numbers) == Array(0..<1_000))
    }
}
