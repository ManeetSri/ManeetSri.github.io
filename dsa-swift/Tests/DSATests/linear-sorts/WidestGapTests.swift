import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WidestGapTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious O(n log n) answer: sort, then look at every pair of neighbours.
    private static func bySorting(_ numbers: [Int]) -> Int {
        let sorted = numbers.sorted()
        return zip(sorted, sorted.dropFirst()).map { $1 - $0 }.max() ?? 0
    }

    @Test("Finds the widest gap", arguments: [
        ([3, 9, 1, 14, 6], 5),
        ([20, 4, 12, 8, 16], 4),
        ([1, 1_000_000_000], 999_999_999),
        ([7, 7, 7], 0),
        ([5, 6], 1),
        ([0, 0, 10, 10], 10),
        ([100, 3, 99, 1, 98, 2], 95),
        ([10], 0),
        ([], 0),
    ])
    func examples(numbers: [Int], expected: Int) {
        #expect(WidestGap.widestGap(in: numbers) == expected)
    }

    @Test("Matches sorting on hundreds of random arrays")
    func randomised() {
        var steps = Steps(seed: 32)
        var firstFailure: [Int]? = nil
        for round in 0..<500 {
            let spread = [2, 10, 100, 1_000, 1_000_000_001][round % 5]
            let numbers = (0..<steps.next(below: 30)).map { _ in steps.next(below: spread) }
            if WidestGap.widestGap(in: numbers) != Self.bySorting(numbers) {
                firstFailure = firstFailure ?? numbers
            }
        }
        #expect(firstFailure == nil, "the first array with the wrong answer")
    }

    @Test("Stays fast on 200,000 values spread up to a billion")
    func largeSpread() {
        var steps = Steps(seed: 9)
        let numbers = (0..<200_000).map { _ in steps.next(below: 1_000_000_001) }
        #expect(WidestGap.widestGap(in: numbers) == Self.bySorting(numbers))
    }

    @Test("Stays fast on 200,000 values in two tight clusters")
    func largeClusters() {
        let numbers = (0..<200_000).map { $0 % 2 == 0 ? $0 / 2 : 999_000_000 + $0 / 2 }
        #expect(WidestGap.widestGap(in: numbers) == 999_000_000 - 99_999)
    }

    @Test("Evenly spaced and all-equal large inputs")
    func largeRegular() {
        #expect(WidestGap.widestGap(in: (0..<200_000).map { $0 * 5_000 }.reversed()) == 5_000)
        #expect(WidestGap.widestGap(in: Array(repeating: 42, count: 200_000)) == 0)
    }
}
