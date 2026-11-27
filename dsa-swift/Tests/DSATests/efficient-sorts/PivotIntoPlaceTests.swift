import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PivotIntoPlaceTests {
    /// True if `numbers` is a correct partition of `original[low...high]` around `original[high]`,
    /// with the pivot at index `p` and everything outside the range untouched.
    private static func isPartitioned(_ numbers: [Int], from original: [Int], low: Int, high: Int, p: Int) -> Bool {
        let pivot = original[high]
        let smaller = original[low...high].filter { $0 < pivot }.count
        guard numbers.count == original.count, p == low + smaller else { return false }
        return numbers[p] == pivot
            && numbers[low..<p].allSatisfy { $0 < pivot }
            && numbers[(p + 1)..<(high + 1)].allSatisfy { $0 >= pivot }
            && numbers[low...high].sorted() == original[low...high].sorted()
            && numbers[..<low] == original[..<low]
            && numbers[(high + 1)...] == original[(high + 1)...]
    }

    @Test("Partitions a whole array around its last element", arguments: [
        ([7, 2, 9, 4, 6], 2),
        ([3, 8, 1, 9, 5], 2),
        ([4, 1, 7, 3, 2], 1),
        ([5, 6, 7, 8, 1], 0),
        ([9, 3, 4, 1, 10], 4),
        ([2, 6, 2, 6, 2, 6, 4], 3),
        ([5, 5, 5, 5], 0),
        ([-3, 8, -9, 0, -1], 2),
        ([1, 2], 1),
        ([2, 1], 0),
        ([42], 0),
    ])
    func wholeArray(numbers: [Int], expected: Int) {
        var copy = numbers
        let p = PivotIntoPlace.partition(&copy, low: 0, high: numbers.count - 1)
        #expect(p == expected)
        #expect(Self.isPartitioned(copy, from: numbers, low: 0, high: numbers.count - 1, p: p))
    }

    @Test("Only touches the range it's given")
    func subrange() {
        let numbers = [100, 7, 2, 9, 4, 6, -100]
        var copy = numbers
        let p = PivotIntoPlace.partition(&copy, low: 1, high: 5)
        #expect(p == 3)
        #expect(copy.first == 100)
        #expect(copy.last == -100)
        #expect(Self.isPartitioned(copy, from: numbers, low: 1, high: 5, p: p))
    }

    @Test("A range of one element is already partitioned")
    func singleElementRange() {
        var numbers = [4, 8, 1]
        #expect(PivotIntoPlace.partition(&numbers, low: 1, high: 1) == 1)
        #expect(numbers == [4, 8, 1])
    }

    @Test("Partitions many small ranges correctly")
    func manySmall() {
        var firstFailure: [Int]? = nil
        for seed in 0..<500 {
            let count = 1 + seed % 12
            let numbers = (0..<count).map { ($0 * 37 + seed * 11) % 9 - 4 }
            let low = seed % 3 < count ? seed % 3 : 0
            let high = count - 1 - (seed % 2 == 1 && count - 2 >= low ? 1 : 0)
            var copy = numbers
            let p = PivotIntoPlace.partition(&copy, low: low, high: high)
            if !Self.isPartitioned(copy, from: numbers, low: low, high: high, p: p) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't partitioned correctly")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 100_000 }
        var copy = numbers
        let high = numbers.count - 1
        let p = PivotIntoPlace.partition(&copy, low: 0, high: high)
        #expect(p == numbers[high])                      // the values are 0..<100,000, each once
        #expect(Self.isPartitioned(copy, from: numbers, low: 0, high: high, p: p))
    }
}
