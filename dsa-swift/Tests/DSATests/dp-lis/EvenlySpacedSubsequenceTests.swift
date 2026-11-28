import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SpacedRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct EvenlySpacedSubsequenceTests {
    /// Tries every subsequence. Slow, but clearly right for small inputs.
    private func bruteForce(_ values: [Int]) -> Int {
        var best = 0
        for mask in 0..<(1 << values.count) {
            let chosen = values.indices.filter { mask & (1 << $0) != 0 }.map { values[$0] }
            let even = chosen.count < 3 || (2..<chosen.count).allSatisfy { chosen[$0] - chosen[$0 - 1] == chosen[1] - chosen[0] }
            if even {
                best = max(best, chosen.count)
            }
        }
        return best
    }

    /// A different algorithm: fix the first two elements of the subsequence, then greedily take the
    /// earliest later occurrence of each next value, found by binary search in that value's positions.
    private func greedyReference(_ values: [Int]) -> Int {
        guard values.count > 2 else { return values.count }
        var positions: [Int: [Int]] = [:]
        for (index, value) in values.enumerated() {
            positions[value, default: []].append(index)
        }
        func firstPosition(of value: Int, after index: Int) -> Int? {
            guard let list = positions[value] else { return nil }
            var low = 0
            var high = list.count
            while low < high {
                let mid = (low + high) / 2
                if list[mid] > index {
                    high = mid
                } else {
                    low = mid + 1
                }
            }
            return low < list.count ? list[low] : nil
        }
        var best = 2
        for first in values.indices {
            for second in (first + 1)..<values.count {
                let step = values[second] - values[first]
                var length = 2
                var index = second
                var value = values[second]
                while let next = firstPosition(of: value + step, after: index) {
                    length += 1
                    index = next
                    value += step
                }
                best = max(best, length)
            }
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        ([1, 7, 10, 13, 14, 19], 4),
        ([9, 4, 7, 2, 10], 3),
        ([20, 1, 15, 3, 10, 5, 8], 4),
        ([5, 5, 5, 5], 4),
        ([1, 1, 2, 2, 3, 3], 3),
        ([3, 6, 9, 12, 1, 2, 3], 4),
        ([8, 3], 2),
        ([8], 1),
        ([], 0),
    ] as [([Int], Int)])
    func examples(values: [Int], expected: Int) {
        #expect(EvenlySpacedSubsequence.longest(values) == expected)
    }

    @Test("Matches brute force on 400 small inputs")
    func randomSmall() {
        var random = SpacedRandom(seed: 58)
        for _ in 0..<400 {
            let values = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: -4...4, using: &random) }
            #expect(EvenlySpacedSubsequence.longest(values) == bruteForce(values), "values: \(values)")
        }
    }

    @Test("Matches the greedy reference on larger inputs")
    func medium() {
        var random = SpacedRandom(seed: 300)
        for _ in 0..<5 {
            let values = (0..<300).map { _ in Int.random(in: -30...30, using: &random) }
            #expect(EvenlySpacedSubsequence.longest(values) == greedyReference(values))
        }

        // 800 wide-ranging values with a progression of 40 hidden at random positions
        var values = (0..<800).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let slots = Array(values.indices).shuffled(using: &random).prefix(40).sorted()
        for (step, slot) in slots.enumerated() {
            values[slot] = -77_777 + 12_345 * step
        }
        let expected = greedyReference(values)
        #expect(expected >= 40)
        #expect(EvenlySpacedSubsequence.longest(values) == expected)
    }

    @Test("800 values with a known answer")
    func large() {
        #expect(EvenlySpacedSubsequence.longest(Array(repeating: -6, count: 800)) == 800)
        #expect(EvenlySpacedSubsequence.longest((0..<800).map { 1_000_000 - 7 * $0 }) == 800)
        // No four different squares are evenly spaced (Fermat stated it, Euler proved it), but 1, 25, 49 are
        #expect(EvenlySpacedSubsequence.longest((0..<800).map { $0 * $0 }) == 3)
    }
}
