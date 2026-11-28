import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoUnpairedNumbersTests {
    @Test("Finds both unpaired values, smaller first", arguments: [
        ([4, 7, 2, 4, 9, 2], [7, 9]),
        ([1, 5], [1, 5]),
        ([5, 1], [1, 5]),
        ([-6, 3, 8, 3, 8, 0], [-6, 0]),
        ([10, 2, 10, 2, 6, 5], [5, 6]),
        ([2, 3], [2, 3]),
        ([8, 8, 12, 4], [4, 12]),
    ])
    func finds(numbers: [Int], expected: [Int]) {
        #expect(TwoUnpairedNumbers.find(in: numbers) == expected)
    }

    @Test("Handles negative values and the extremes of the range")
    func extremes() {
        #expect(TwoUnpairedNumbers.find(in: [-1_000_000_000, 7, 7, 1_000_000_000]) == [-1_000_000_000, 1_000_000_000])
        #expect(TwoUnpairedNumbers.find(in: [-1, -2, -3, -1]) == [-3, -2])
    }

    @Test("Matches a dictionary count on many arrays")
    func matchesCounting() {
        var firstMismatch: [Int]? = nil
        for seed in 1...200 {
            let pairs = (0..<(seed % 6)).map { $0 * 3 - seed }
            let singles = [seed * 7 + 1, -seed * 5]
            var numbers = pairs + pairs + singles
            numbers.rotate(by: seed)
            if TwoUnpairedNumbers.find(in: numbers) != singles.sorted() {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array with a wrong answer")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let pairs = Array(1...49_999)
        let numbers = pairs + [123_456_789, -42] + pairs.reversed()
        #expect(TwoUnpairedNumbers.find(in: numbers) == [-42, 123_456_789])
    }
}

private extension Array {
    // Moves the first `count % self.count` elements to the end, so pairs and singles get mixed up
    mutating func rotate(by count: Int) {
        guard !isEmpty else { return }
        let shift = count % self.count
        self = Array(self[shift...] + self[..<shift])
    }
}
