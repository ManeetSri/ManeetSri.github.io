import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MinAndMaxTogetherTests {
    @Test("Finds both ends", arguments: [
        ([3, 9, 4], 3, 9),
        ([5, 1, 8, 2], 1, 8),
        ([1, 2, 3, 4, 5], 1, 5),
        ([5, 4, 3, 2, 1], 1, 5),
        ([-5, -2, -8], -8, -2),
        ([-3, 0, 3], -3, 3),
    ])
    func findsBoth(numbers: [Int], expectedMin: Int, expectedMax: Int) throws {
        let result = try #require(MinAndMaxTogether.minAndMax(of: numbers))
        #expect(result.min == expectedMin)
        #expect(result.max == expectedMax)
    }

    @Test("A single number is both the smallest and the largest")
    func single() throws {
        let result = try #require(MinAndMaxTogether.minAndMax(of: [7]))
        #expect(result.min == 7)
        #expect(result.max == 7)
    }

    @Test("Handles repeated numbers")
    func repeated() throws {
        let result = try #require(MinAndMaxTogether.minAndMax(of: [4, 4, 4]))
        #expect(result.min == 4)
        #expect(result.max == 4)
    }

    @Test("Returns nil for an empty array")
    func empty() {
        #expect(MinAndMaxTogether.minAndMax(of: []) == nil)
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() throws {
        let result = try #require(MinAndMaxTogether.minAndMax(of: [0, 1_000_000_000, -1_000_000_000]))
        #expect(result.min == -1_000_000_000)
        #expect(result.max == 1_000_000_000)
    }

    @Test("Stays fast on 100,000 numbers")
    func large() throws {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 100_003 - 50_000 }
        let result = try #require(MinAndMaxTogether.minAndMax(of: numbers))
        #expect(result.min == numbers.min())
        #expect(result.max == numbers.max())
    }
}
