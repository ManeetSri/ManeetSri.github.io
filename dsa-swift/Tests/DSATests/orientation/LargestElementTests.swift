import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LargestElementTests {
    @Test("Finds the largest", arguments: [
        ([3, 9, 4], 9),
        ([7], 7),
        ([1, 2, 3, 4, 5], 5),
        ([5, 4, 3, 2, 1], 5),
        ([4, 4, 4], 4),
    ])
    func findsLargest(numbers: [Int], expected: Int) {
        #expect(LargestElement.largest(in: numbers) == expected)
    }

    @Test("Works when every number is negative")
    func allNegative() {
        #expect(LargestElement.largest(in: [-5, -2, -8]) == -2)
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() {
        #expect(LargestElement.largest(in: [-1_000_000_000, 1_000_000_000, 0]) == 1_000_000_000)
    }

    @Test("Returns nil for an empty array")
    func empty() {
        #expect(LargestElement.largest(in: []) == nil)
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 100_003 }
        #expect(LargestElement.largest(in: numbers) == numbers.max())
    }
}
