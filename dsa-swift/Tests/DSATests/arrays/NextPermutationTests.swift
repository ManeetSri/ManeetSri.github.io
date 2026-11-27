import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NextPermutationTests {
    @Test("Moves to the next arrangement", arguments: [
        ([1, 2, 3], [1, 3, 2]),
        ([1, 3, 2], [2, 1, 3]),
        ([2, 3, 1], [3, 1, 2]),
        ([1, 5, 8, 4, 7, 6, 5, 3, 1], [1, 5, 8, 5, 1, 3, 4, 6, 7]),
        ([0, 1], [1, 0]),
        ([4, 1, 9, 9, 2], [4, 2, 1, 9, 9]),
        ([-2, 7, -5], [7, -5, -2]),
    ])
    func advances(numbers: [Int], expected: [Int]) {
        var values = numbers
        #expect(NextPermutation.advance(&values))
        #expect(values == expected)
    }

    @Test("Handles repeated values", arguments: [
        ([1, 1, 2], [1, 2, 1]),
        ([1, 2, 1], [2, 1, 1]),
        ([2, 2, 3, 3], [2, 3, 2, 3]),
        ([3, 1, 1, 3], [3, 1, 3, 1]),
    ])
    func repeats(numbers: [Int], expected: [Int]) {
        var values = numbers
        #expect(NextPermutation.advance(&values))
        #expect(values == expected)
    }

    @Test("Wraps from the last arrangement to the first", arguments: [
        ([3, 2, 1], [1, 2, 3]),
        ([2, 1, 1], [1, 1, 2]),
        ([5, 5, 5], [5, 5, 5]),
        ([9], [9]),
        ([], []),
    ])
    func wraps(numbers: [Int], expected: [Int]) {
        var values = numbers
        #expect(!NextPermutation.advance(&values))
        #expect(values == expected)
    }

    @Test("Visits every arrangement of four values exactly once")
    func allArrangements() {
        var values = [1, 2, 3, 4]
        var seen: [[Int]] = [values]
        var steps = 0
        while NextPermutation.advance(&values) && steps < 100 {
            seen.append(values)
            steps += 1
        }
        #expect(seen.count == 24)
        #expect(seen == seen.sorted { $0.lexicographicallyPrecedes($1) })
        #expect(Set(seen).count == 24)
        #expect(values == [1, 2, 3, 4])
    }

    @Test("Visits every distinct arrangement once when values repeat")
    func distinctArrangements() {
        var values = [1, 1, 2, 2]
        var count = 1
        while NextPermutation.advance(&values) && count < 100 {
            count += 1
        }
        #expect(count == 6)
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        var descending = Array((0..<100_000).reversed())
        #expect(!NextPermutation.advance(&descending))
        #expect(descending == Array(0..<100_000))

        var values = Array(0..<100_000)
        values.swapAt(1, 2)                  // [0, 2, 1, 3, 4, …]
        #expect(NextPermutation.advance(&values))
        var expected = Array(0..<100_000)
        expected.swapAt(1, 2)
        expected.swapAt(99_998, 99_999)
        #expect(values == expected)

        var almostLast = [0] + Array((1..<100_000).reversed())
        #expect(NextPermutation.advance(&almostLast))
        #expect(almostLast == [1, 0] + Array(2..<100_000))
    }
}
