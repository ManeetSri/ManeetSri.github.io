import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BalancePointIndexTests {
    @Test("Finds the leftmost balance point", arguments: [
        ([2, 3, -1, 8, 4], 3),
        ([3, -3, 7], 2),
        ([7, 3, -3], 0),
        ([5], 0),
        ([0, 0, 0], 0),
        ([-2, 5, -2, 0], 1),
        ([1, 4, 2, 5], 2),
        ([4, 1, 4, 9, 9], 3),
        ([-1, -1, -1, 0, 1, 1], 0),
    ])
    func finds(numbers: [Int], expected: Int) {
        #expect(BalancePointIndex.balancePoint(in: numbers) == expected)
    }

    @Test("Returns nil when nothing balances", arguments: [
        [Int](),
        [1, 2, 3],
        [1, 1],
        [2, -2],
        [10, -5, 1],
    ])
    func noBalancePoint(numbers: [Int]) {
        #expect(BalancePointIndex.balancePoint(in: numbers) == nil)
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<400 {
            let numbers = (0..<(seed % 9)).map { ($0 * 11 + seed * 5) % 9 - 4 }
            let expected = numbers.indices.first { i in
                numbers[..<i].reduce(0, +) == numbers[(i + 1)...].reduce(0, +)
            }
            if BalancePointIndex.balancePoint(in: numbers) != expected {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on large arrays")
    func large() {
        let balanced = Array(repeating: 1, count: 50_000) + [123] + Array(repeating: 2, count: 25_000)
        #expect(BalancePointIndex.balancePoint(in: balanced) == 50_000)

        let evenOnes = Array(repeating: 1, count: 100_000)
        #expect(BalancePointIndex.balancePoint(in: evenOnes) == nil)

        let oddOnes = Array(repeating: 1, count: 99_999)
        #expect(BalancePointIndex.balancePoint(in: oddOnes) == 49_999)
    }
}
