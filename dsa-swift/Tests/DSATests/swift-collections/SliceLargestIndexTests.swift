import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SliceLargestIndexTests {
    static let numbers = [4, 8, 1, 9, 3, 9, 2]

    @Test("Returns the index in the original array", arguments: [
        (2..<6, 3),
        (4..<7, 5),
        (0..<3, 1),
        (6..<7, 6),
        (5..<7, 5),
        (0..<7, 3),
        (1..<3, 1),
    ])
    func originalIndex(range: Range<Int>, expected: Int) {
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[range]) == expected)
    }

    @Test("Works with one-sided ranges")
    func oneSided() {
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[4...]) == 5)
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[..<3]) == 1)
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[...]) == 3)
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers.dropFirst(4)) == 5)
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers.suffix(2)) == 5)
    }

    @Test("Ties give the smallest index")
    func ties() {
        #expect(SliceLargestIndex.indexOfLargest(in: [5, 5, 5, 5][1...]) == 1)
        #expect(SliceLargestIndex.indexOfLargest(in: [0, 7, 2, 7, 7][2...]) == 3)
    }

    @Test("Empty slices give nil, wherever they are")
    func empty() {
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[3..<3]) == nil)
        #expect(SliceLargestIndex.indexOfLargest(in: Self.numbers[7...]) == nil)
        #expect(SliceLargestIndex.indexOfLargest(in: [Int]()[...]) == nil)
    }

    @Test("A slice of a slice keeps the original indexes")
    func sliceOfSlice() {
        let outer = Self.numbers[1...5]
        #expect(SliceLargestIndex.indexOfLargest(in: outer[4...]) == 5)
        #expect(SliceLargestIndex.indexOfLargest(in: outer[1..<3]) == 1)
        #expect(SliceLargestIndex.indexOfLargest(in: outer.dropFirst().dropLast()) == 3)
    }

    @Test("Handles negative values")
    func negatives() {
        let values = [-1, -9, -4, -2, -7]
        #expect(SliceLargestIndex.indexOfLargest(in: values[1...]) == 3)
        #expect(SliceLargestIndex.indexOfLargest(in: values[1...2]) == 2)
        #expect(SliceLargestIndex.indexOfLargest(in: [-1_000_000_000, -999_999_999][...]) == 1)
    }

    @Test("Stays fast on a slice of 100,000 elements")
    func large() {
        let values = (0..<150_000).map { ($0 * 7_919) % 100_003 }
        let window = values[25_000..<125_000]
        var expected = 25_000
        for i in 25_000..<125_000 where values[i] > values[expected] {
            expected = i
        }
        #expect(SliceLargestIndex.indexOfLargest(in: window) == expected)
    }
}
