import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RisingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LongestRisingSubsequenceTests {
    /// Tries every subsequence. Slow, but clearly right for small inputs.
    private func bruteForce(_ readings: [Int]) -> Int {
        var best = 0
        for mask in 0..<(1 << readings.count) {
            var previous = 0
            var length = 0
            var rising = true
            for (index, reading) in readings.enumerated() where mask & (1 << index) != 0 {
                if length > 0 && reading <= previous {
                    rising = false
                    break
                }
                previous = reading
                length += 1
            }
            if rising {
                best = max(best, length)
            }
        }
        return best
    }

    /// A different algorithm for big inputs: for each reading, a Fenwick tree over the readings' ranks
    /// gives the longest run ending at any smaller value seen so far.
    private func fenwickReference(_ readings: [Int]) -> Int {
        let distinct = Array(Set(readings)).sorted()
        var rank: [Int: Int] = [:]
        for (index, value) in distinct.enumerated() {
            rank[value] = index + 1
        }
        var tree = Array(repeating: 0, count: distinct.count + 1)
        var best = 0
        for reading in readings {
            let position = rank[reading]!
            var index = position - 1
            var below = 0
            while index > 0 {
                below = max(below, tree[index])
                index -= index & -index
            }
            best = max(best, below + 1)
            index = position
            while index < tree.count {
                tree[index] = max(tree[index], below + 1)
                index += index & -index
            }
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        ([10, 9, 2, 5, 3, 7, 101, 18], 4),
        ([3, 4, 5, 1, 2], 3),
        ([0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15], 6),
        ([], 0),
        ([7], 1),
        ([7, 7, 7], 1),
        ([1, 2, 2, 3], 3),
        ([1, 2, 3, 4], 4),
        ([4, 3, 2, 1], 1),
        ([-3, -1, -2, 0, -5], 3),
        ([1_000_000_000, -1_000_000_000, 0, 999_999_999], 3),
    ] as [([Int], Int)])
    func examples(readings: [Int], expected: Int) {
        #expect(LongestRisingSubsequence.length(of: readings) == expected)
    }

    @Test("Matches brute force on 500 small inputs with repeated values")
    func randomSmall() {
        var random = RisingRandom(seed: 55)
        for _ in 0..<500 {
            let readings = (0..<Int.random(in: 0...12, using: &random)).map { _ in Int.random(in: -5...5, using: &random) }
            #expect(LongestRisingSubsequence.length(of: readings) == bruteForce(readings), "readings: \(readings)")
        }
    }

    @Test("100,000 readings with a known answer (needs O(n log n))")
    func largeKnown() {
        let n = 100_000
        #expect(LongestRisingSubsequence.length(of: Array(0..<n)) == n)
        #expect(LongestRisingSubsequence.length(of: Array((0..<n).reversed())) == 1)
        #expect(LongestRisingSubsequence.length(of: Array(repeating: 42, count: n)) == 1)
        #expect(LongestRisingSubsequence.length(of: (0..<n).map { $0 % 1_000 }) == 1_000)

        // Blocks whose values only go down, each block entirely above the one before: a rising
        // subsequence takes at most one reading per block, and can take one from every block.
        var random = RisingRandom(seed: 1_955)
        var readings: [Int] = []
        var blocks = 0
        while readings.count < n {
            let base = blocks * 1_000
            let size = Int.random(in: 1...60, using: &random)
            var value = base + 999
            for _ in 0..<size where readings.count < n {
                readings.append(value)
                value -= Int.random(in: 0...20, using: &random)
                value = max(value, base)
            }
            blocks += 1
        }
        #expect(LongestRisingSubsequence.length(of: readings) == blocks)
    }

    @Test("100,000 random readings match a Fenwick-tree reference")
    func largeRandom() {
        var random = RisingRandom(seed: 28)
        for range in [1_000_000_000, 5_000] {
            let readings = (0..<100_000).map { _ in Int.random(in: -range...range, using: &random) }
            #expect(LongestRisingSubsequence.length(of: readings) == fenwickReference(readings))
        }
    }
}
