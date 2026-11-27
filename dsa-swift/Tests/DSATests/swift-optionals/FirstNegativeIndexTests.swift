import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FirstNegativeIndexTests {
    @Test("Finds the first negative number", arguments: [
        ([4, 7, -2, 9], 2),
        ([-1, 5, 8], 0),
        ([3, 6, 9, -4], 3),
        ([5, -3, -8, -1], 1),
        ([-9], 0),
    ])
    func finds(numbers: [Int], expected: Int) {
        #expect(FirstNegativeIndex.find(in: numbers) == expected)
    }

    @Test("Returns nil when nothing is negative", arguments: [[4, 7, 12, 9], [0, 0, 0], [1], [0]])
    func noneNegative(numbers: [Int]) {
        #expect(FirstNegativeIndex.find(in: numbers) == nil)
    }

    @Test("Zero is not negative")
    func zeroIsNotNegative() {
        #expect(FirstNegativeIndex.find(in: [0, 3, 0, -1]) == 3)
    }

    @Test("Returns nil for an empty array")
    func empty() {
        #expect(FirstNegativeIndex.find(in: []) == nil)
    }

    @Test("Works on 100,000 numbers")
    func large() {
        var numbers = Array(repeating: 1, count: 100_000)
        #expect(FirstNegativeIndex.find(in: numbers) == nil)
        numbers[99_999] = -1
        numbers[75_000] = -5
        #expect(FirstNegativeIndex.find(in: numbers) == 75_000)
    }
}
