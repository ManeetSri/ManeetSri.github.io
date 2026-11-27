import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SecondLargestDistinctTests {
    @Test("Finds the second-largest distinct value", arguments: [
        ([4, 9, 7], 7),
        ([9, 4, 9, 7], 7),
        ([-3, -8], -8),
        ([1, 2, 3, 4, 5], 4),
        ([5, 4, 3, 2, 1], 4),
        ([9, 9, 4], 4),
        ([9, 4, 4], 4),
        ([7, 7, 8], 7),
        ([8, 7, 7, 8], 7),
        ([-1, -1, -2, -2], -2),
    ])
    func secondLargest(numbers: [Int], expected: Int) {
        #expect(SecondLargestDistinct.secondLargest(in: numbers) == expected)
    }

    @Test("Returns nil when there's no second distinct value", arguments: [
        [Int](),
        [6],
        [5, 5, 5],
        [-4, -4],
    ])
    func noAnswer(numbers: [Int]) {
        #expect(SecondLargestDistinct.secondLargest(in: numbers) == nil)
    }

    @Test("Handles the extremes of the allowed values")
    func extremes() {
        #expect(SecondLargestDistinct.secondLargest(in: [-1_000_000_000, 1_000_000_000]) == -1_000_000_000)
        #expect(SecondLargestDistinct.secondLargest(in: [1_000_000_000, 0, 1_000_000_000]) == 0)
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<400 {
            let numbers = (0..<(seed % 7)).map { ($0 * 5 + seed * 3) % 7 - 3 }
            let expected = Set(numbers).sorted().dropLast().last
            if SecondLargestDistinct.secondLargest(in: numbers) != expected {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() {
        let numbers = Array(1...100_000)
        #expect(SecondLargestDistinct.secondLargest(in: numbers) == 99_999)
        #expect(SecondLargestDistinct.secondLargest(in: numbers.reversed()) == 99_999)
    }
}
