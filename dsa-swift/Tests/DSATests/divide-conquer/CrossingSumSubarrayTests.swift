import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CrossingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CrossingSumSubarrayTests {
    /// Kadane's algorithm: the best run ending at each index
    private func kadane(_ numbers: [Int]) -> Int {
        var current = numbers[0]
        var best = numbers[0]
        for value in numbers.dropFirst() {
            current = max(value, current + value)
            best = max(best, current)
        }
        return best
    }

    /// Every run, with a running sum per start
    private func bruteForce(_ numbers: [Int]) -> Int {
        var best = numbers[0]
        for start in numbers.indices {
            var sum = 0
            for end in start..<numbers.count {
                sum += numbers[end]
                best = max(best, sum)
            }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([4, -6, 3, 5, -1, 2, -8, 4], 9),
        ([-7, -3, -9], -3),
        ([5], 5),
        ([-5], -5),
        ([2, -1, 2, -1, 2], 4),
        ([-2, 6, -9, 6, -2], 6),
        ([1, 2, 3], 6),
        ([0, -1, 0], 0),
        ([3, -4, 5], 5),
        ([-1, 4, -1, 4, -1], 7),
        ([10, -20, 15], 15),
    ] as [([Int], Int)])
    func examples(numbers: [Int], expected: Int) {
        #expect(CrossingSumSubarray.bestSum(numbers) == expected)
    }

    @Test("Matches the brute force on 500 small random arrays")
    func randomSmall() {
        var random = CrossingRandom(seed: 49)
        for _ in 0..<500 {
            let numbers = (0..<Int.random(in: 1...25, using: &random)).map { _ in Int.random(in: -15...15, using: &random) }
            #expect(CrossingSumSubarray.bestSum(numbers) == bruteForce(numbers))
        }
    }

    @Test("100,000 random values match Kadane")
    func largeRandom() {
        var random = CrossingRandom(seed: 1_984)
        let numbers = (0..<100_000).map { _ in Int.random(in: -10_000...10_000, using: &random) }
        #expect(CrossingSumSubarray.bestSum(numbers) == kadane(numbers))
    }

    @Test("Large arrays: all negative, all positive, and a best run straddling the middle")
    func largeShapes() {
        var random = CrossingRandom(seed: 7)
        let negatives = (0..<50_000).map { _ in Int.random(in: -10_000 ... -1, using: &random) }
        #expect(CrossingSumSubarray.bestSum(negatives) == negatives.max()!)

        let positives = Array(repeating: 10_000, count: 50_000)
        #expect(CrossingSumSubarray.bestSum(positives) == 500_000_000)

        // Losses everywhere except a profitable stretch across the centre
        var straddle = Array(repeating: -3, count: 50_001)
        for index in 20_000...30_000 {
            straddle[index] = 2
        }
        #expect(CrossingSumSubarray.bestSum(straddle) == 2 * 10_001)
    }
}
