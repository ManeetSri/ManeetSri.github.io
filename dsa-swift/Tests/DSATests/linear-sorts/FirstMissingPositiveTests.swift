import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FirstMissingPositiveTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious answer with a Set: try 1, 2, 3, … until one is missing.
    private static func withSet(_ numbers: [Int]) -> Int {
        let present = Set(numbers)
        var candidate = 1
        while present.contains(candidate) { candidate += 1 }
        return candidate
    }

    private static func find(_ numbers: [Int]) -> Int {
        var copy = numbers
        return FirstMissingPositive.find(in: &copy)
    }

    @Test("Finds the first missing positive", arguments: [
        ([7, 3, -2, 1, 9, 2], 4),
        ([2, 1, 3], 4),
        ([0, -5, 8], 1),
        ([1, 1], 2),
        ([2], 1),
        ([1], 2),
        ([3, 4, 1, 2], 5),
        ([5, 3, -1, 1, 4], 2),
        ([2, 2, 2, 2], 1),
        ([], 1),
    ])
    func examples(numbers: [Int], expected: Int) {
        #expect(Self.find(numbers) == expected)
    }

    @Test("Ignores extreme values safely")
    func extremes() {
        #expect(Self.find([Int.max, 2, 1]) == 3)
        #expect(Self.find([-3, 0, Int.min]) == 1)
        #expect(Self.find([Int.min, Int.max, 1, Int.min]) == 2)
        #expect(Self.find([1, Int.max - 1, 2, Int.min + 1]) == 3)
    }

    @Test("Matches a Set-based answer on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 41)
        var firstFailure: [Int]? = nil
        for _ in 0..<500 {
            let count = steps.next(below: 25)
            let numbers = (0..<count).map { _ in steps.next(below: count + 6) - 3 }
            if Self.find(numbers) != Self.withSet(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array with the wrong answer")
    }

    @Test("Stays fast on large inputs")
    func large() {
        let n = 200_000
        let permutation = (0..<n).map { ($0 * 7_919) % n + 1 }
        #expect(Self.find(permutation) == n + 1)

        var oneGone = permutation
        oneGone[oneGone.firstIndex(of: 123_456)!] = -1
        #expect(Self.find(oneGone) == 123_456)

        let noise = (0..<n).map { $0 % 3 == 0 ? -$0 : $0 * 1_000 }
        #expect(Self.find(noise) == 1)

        #expect(Self.find(Array(repeating: 1, count: n)) == 2)
        #expect(Self.find(Array((1...n).reversed())) == n + 1)
    }
}
