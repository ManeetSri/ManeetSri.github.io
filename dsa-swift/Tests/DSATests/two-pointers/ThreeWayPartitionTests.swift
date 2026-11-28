import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ThreeWayPartitionTests {
    /// True if `numbers` is a correct partition of `original` around `pivot`, with the equal block at `range`.
    private static func isPartitioned(_ numbers: [Int], from original: [Int], around pivot: Int, range: Range<Int>) -> Bool {
        guard range.lowerBound >= 0, range.upperBound <= numbers.count else { return false }
        let less = original.filter { $0 < pivot }.count
        let equal = original.filter { $0 == pivot }.count
        return range == less..<(less + equal)
            && numbers.sorted() == original.sorted()
            && numbers[..<range.lowerBound].allSatisfy { $0 < pivot }
            && numbers[range].allSatisfy { $0 == pivot }
            && numbers[range.upperBound...].allSatisfy { $0 > pivot }
    }

    @Test("Partitions around the pivot", arguments: [
        ([2, 0, 2, 1, 1, 0, 1, 2, 0], 1),
        ([5, 1, 9, 5, 3, 5, 7], 5),
        ([4, 1, 7], 5),
        ([3, 3, 3], 3),
        ([9, 8], 1),
        ([1, 2], 9),
        ([-4, 10, -4, 0, 10, 3], 0),
        ([6], 6),
        ([], 3),
    ])
    func partitions(numbers: [Int], pivot: Int) {
        var copy = numbers
        let range = ThreeWayPartition.partition(&copy, around: pivot)
        #expect(Self.isPartitioned(copy, from: numbers, around: pivot, range: range))
    }

    @Test("Returns the range of the pivot's copies", arguments: [
        ([2, 0, 2, 1, 1, 0, 1, 2, 0], 1, 3..<6),
        ([5, 1, 9, 5, 3, 5, 7], 5, 2..<5),
        ([4, 1, 7], 5, 2..<2),
        ([9, 8], 1, 0..<0),
        ([3, 3, 3], 3, 0..<3),
        ([], 3, 0..<0),
    ])
    func range(numbers: [Int], pivot: Int, expected: Range<Int>) {
        var copy = numbers
        #expect(ThreeWayPartition.partition(&copy, around: pivot) == expected)
    }

    @Test("Partitions many small arrays correctly")
    func manySmall() {
        var firstFailure: [Int]? = nil
        for seed in 0..<400 {
            let numbers = (0..<(seed % 10)).map { ($0 * 7 + seed * 3) % 6 }
            let pivot = seed % 7
            var copy = numbers
            let range = ThreeWayPartition.partition(&copy, around: pivot)
            if !Self.isPartitioned(copy, from: numbers, around: pivot, range: range) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array that wasn't partitioned correctly")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 1_000 }
        var copy = numbers
        let range = ThreeWayPartition.partition(&copy, around: 500)
        #expect(range == 50_000..<50_100)
        #expect(Self.isPartitioned(copy, from: numbers, around: 500, range: range))
    }
}
