import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SortedCommonTests {
    @Test("Finds the shared values in ascending order", arguments: [
        ([4, 9, 5], [9, 4, 9, 8, 4], [4, 9]),
        ([1, 2, 3], [3, 2, 1], [1, 2, 3]),
        ([10, -3, 7], [7, -3], [-3, 7]),
        ([1, 1, 1], [1], [1]),
    ])
    func findsCommon(first: [Int], second: [Int], expected: [Int]) {
        #expect(SortedCommon.common(first, second) == expected)
    }

    @Test("Returns an empty array when nothing is shared")
    func nothingShared() {
        #expect(SortedCommon.common([1, 3, 5], [2, 4, 6]) == [])
    }

    @Test("Handles empty inputs")
    func empty() {
        #expect(SortedCommon.common([], [1, 2]) == [])
        #expect(SortedCommon.common([1, 2], []) == [])
        #expect(SortedCommon.common([], []) == [])
    }

    @Test("Stays fast on large inputs")
    func large() {
        let evens = Array(stride(from: 0, to: 200_000, by: 2))
        let threes = Array(stride(from: 0, to: 200_000, by: 3))
        let expected = Array(stride(from: 0, to: 200_000, by: 6))
        #expect(SortedCommon.common(evens.reversed(), threes) == expected)
    }
}
