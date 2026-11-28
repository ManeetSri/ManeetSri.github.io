import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CountRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LongestRisingCountTests {
    /// Lists every subsequence, keeps the rising ones, and counts those of the greatest length.
    private func bruteForce(_ values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        var bestLength = 0
        var count = 0
        for mask in 1..<(1 << values.count) {
            var previous = 0
            var length = 0
            var rising = true
            for (index, value) in values.enumerated() where mask & (1 << index) != 0 {
                if length > 0 && value <= previous {
                    rising = false
                    break
                }
                previous = value
                length += 1
            }
            guard rising else { continue }
            if length > bestLength {
                bestLength = length
                count = 1
            } else if length == bestLength {
                count += 1
            }
        }
        return count
    }

    /// The O(n²) counting DP, with every addition checked so a test input can never overflow silently.
    private func reference(_ values: [Int]) -> (count: Int, overflowed: Bool) {
        var length = Array(repeating: 1, count: values.count)
        var ways = Array(repeating: 1, count: values.count)
        var overflowed = false
        for i in values.indices {
            for j in 0..<i where values[j] < values[i] {
                if length[j] + 1 > length[i] {
                    length[i] = length[j] + 1
                    ways[i] = ways[j]
                } else if length[j] + 1 == length[i] {
                    let (sum, overflow) = ways[i].addingReportingOverflow(ways[j])
                    ways[i] = sum
                    overflowed = overflowed || overflow
                }
            }
        }
        let best = length.max() ?? 0
        var total = 0
        for i in values.indices where length[i] == best {
            let (sum, overflow) = total.addingReportingOverflow(ways[i])
            total = sum
            overflowed = overflowed || overflow
        }
        return (total, overflowed)
    }

    @Test("Examples and edge cases", arguments: [
        ([1, 3, 5, 4, 7], 2),
        ([3, 1, 4, 2, 5], 3),
        ([2, 2, 2, 2, 2], 5),
        ([1, 4, 2, 5, 3, 6], 3),
        ([1, 2, 2], 2),
        ([5, 4, 3, 2, 1], 5),
        ([1, 2, 3, 4, 5], 1),
        ([9], 1),
        ([], 0),
        ([-1, -1, 0, 0], 4),
    ] as [([Int], Int)])
    func examples(values: [Int], expected: Int) {
        #expect(LongestRisingCount.count(values) == expected)
    }

    @Test("Matches brute force on 400 small inputs with repeated values")
    func randomSmall() {
        var random = CountRandom(seed: 3)
        for _ in 0..<400 {
            let values = (0..<Int.random(in: 0...12, using: &random)).map { _ in Int.random(in: 0...5, using: &random) }
            #expect(LongestRisingCount.count(values) == bruteForce(values), "values: \(values)")
        }
    }

    @Test("Thirty swapped pairs give 2^30 longest subsequences")
    func pairs() {
        // [1, 0, 3, 2, 5, 4, …]: every pair offers two choices
        let values = (0..<30).flatMap { [2 * $0 + 1, 2 * $0] }
        #expect(LongestRisingCount.count(values) == 1 << 30)
    }

    @Test("1,000 values")
    func large() throws {
        let n = 1_000
        #expect(LongestRisingCount.count(Array(0..<n)) == 1)
        #expect(LongestRisingCount.count(Array((0..<n).reversed())) == n)
        #expect(LongestRisingCount.count(Array(repeating: 7, count: n)) == n)

        var random = CountRandom(seed: 1_000)
        let values = (0..<n).map { _ in Int.random(in: 0..<1_000_000, using: &random) }
        let expected = reference(values)
        try #require(!expected.overflowed)
        #expect(LongestRisingCount.count(values) == expected.count)
    }
}
