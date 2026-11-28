import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NearestFirstOrderTests {
    @Test("Sorts by distance from the target", arguments: [
        ([1, 9, 4, 6, 5], 5, [5, 4, 6, 1, 9]),
        ([10, -2, 3], 0, [-2, 3, 10]),
        ([20, 30], 100, [30, 20]),
        ([100, 50, 0], -10, [0, 50, 100]),
        ([3, 1, 2], 2, [2, 1, 3]),
    ])
    func byDistance(numbers: [Int], target: Int, expected: [Int]) {
        #expect(NearestFirstOrder.sorted(numbers, around: target) == expected)
    }

    @Test("Equally close numbers go smallest first", arguments: [
        ([7, 3, 7, 3], 5, [3, 3, 7, 7]),
        ([6, 4], 5, [4, 6]),
        ([2, -2, 0], 0, [0, -2, 2]),
        ([-5, 5, -1, 1], 0, [-1, 1, -5, 5]),
    ])
    func ties(numbers: [Int], target: Int, expected: [Int]) {
        #expect(NearestFirstOrder.sorted(numbers, around: target) == expected)
    }

    @Test("Keeps repeats")
    func repeats() {
        #expect(NearestFirstOrder.sorted([4, 4, 4], around: 9) == [4, 4, 4])
        #expect(NearestFirstOrder.sorted([8, 1, 8, 1, 5], around: 6) == [5, 8, 8, 1, 1])
    }

    @Test("Handles empty and single-element arrays")
    func small() {
        #expect(NearestFirstOrder.sorted([], around: 4) == [])
        #expect(NearestFirstOrder.sorted([42], around: -7) == [42])
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() {
        let numbers = [1_000_000, -1_000_000, 0]
        #expect(NearestFirstOrder.sorted(numbers, around: 1_000_000) == [1_000_000, 0, -1_000_000])
        #expect(NearestFirstOrder.sorted(numbers, around: -1_000_000) == [-1_000_000, 0, 1_000_000])
    }

    @Test("Stays fast on 100,000 numbers, and keeps every one")
    func large() throws {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 20_011 - 10_000 }
        let target = 123
        let result = NearestFirstOrder.sorted(numbers, around: target)
        try #require(result.count == numbers.count)
        #expect(result.sorted() == numbers.sorted())
        var inOrder = true
        for i in 1..<result.count {
            let previous = (abs(result[i - 1] - target), result[i - 1])
            let current = (abs(result[i] - target), result[i])
            if previous > current {
                inOrder = false
                break
            }
        }
        #expect(inOrder)
    }
}
