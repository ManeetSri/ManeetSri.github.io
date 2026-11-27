import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BandRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SubarraySumsInBandTests {
    /// Tries every slice. O(n²), but clearly right.
    private func reference(_ values: [Int], _ low: Int, _ high: Int) -> Int {
        var count = 0
        for start in values.indices {
            var sum = 0
            for end in start..<values.count {
                sum += values[end]
                if low <= sum && sum <= high { count += 1 }
            }
        }
        return count
    }

    /// An independent fast reference: merge sort over the prefix sums, counting, for each prefix in
    /// the right half, the prefixes in the left half within the band with two moving pointers.
    private func mergeReference(_ values: [Int], _ low: Int, _ high: Int) -> Int {
        var prefix = [0]
        for value in values { prefix.append(prefix.last! + value) }
        var buffer = prefix
        func sortAndCount(_ start: Int, _ end: Int) -> Int {      // prefix[start..<end]
            if end - start <= 1 { return 0 }
            let mid = (start + end) / 2
            var count = sortAndCount(start, mid) + sortAndCount(mid, end)
            var lowPointer = start, highPointer = start
            for j in mid..<end {                                   // both halves are sorted now
                while lowPointer < mid && prefix[lowPointer] < prefix[j] - high { lowPointer += 1 }
                while highPointer < mid && prefix[highPointer] <= prefix[j] - low { highPointer += 1 }
                count += highPointer - lowPointer
            }
            var i = start, j = mid, k = start
            while i < mid || j < end {
                if j == end || (i < mid && prefix[i] <= prefix[j]) {
                    buffer[k] = prefix[i]
                    i += 1
                } else {
                    buffer[k] = prefix[j]
                    j += 1
                }
                k += 1
            }
            for index in start..<end { prefix[index] = buffer[index] }
            return count
        }
        return sortAndCount(0, prefix.count)
    }

    @Test("Examples and small cases", arguments: [
        ([2, -1, 3, -2, 4], 1, 3, 7),
        ([], 0, 0, 0),
        ([5], 5, 5, 1),
        ([5], 6, 10, 0),
        ([0, 0, 0], 0, 0, 6),
        ([1, 2, 3], 10, 1, 0),
        ([-2, -2, -2], -4, -2, 5),
        ([1_000_000_000, 1_000_000_000, -1_000_000_000], 1_000_000_000, 2_000_000_000, 4),
    ] as [([Int], Int, Int, Int)])
    func examples(values: [Int], low: Int, high: Int, expected: Int) {
        #expect(SubarraySumsInBand.count(values, low: low, high: high) == expected)
    }

    @Test("Matches trying every slice on 400 small random arrays")
    func randomSmall() {
        var random = BandRandom(seed: 69)
        for _ in 0..<400 {
            let values = (0..<Int.random(in: 0...14, using: &random)).map { _ in Int.random(in: -6...6, using: &random) }
            let a = Int.random(in: -10...10, using: &random), b = Int.random(in: -10...10, using: &random)
            #expect(SubarraySumsInBand.count(values, low: min(a, b), high: max(a, b)) == reference(values, min(a, b), max(a, b)))
        }
    }

    @Test("Every slice of 100,000 positive values is in a wide enough band")
    func everySlice() {
        let values = Array(repeating: 3, count: 100_000)
        #expect(SubarraySumsInBand.count(values, low: 3, high: 300_000) == 100_000 * 100_001 / 2)
        #expect(SubarraySumsInBand.count(values, low: 6, high: 6) == 99_999)
    }

    @Test("100,000 random values")
    func large() {
        // Trying every slice would add up 5 × 10⁹ of them
        var random = BandRandom(seed: 2_035)
        let values = (0..<100_000).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let expected = mergeReference(values, -5_000_000_000, 20_000_000_000)
        #expect(expected > 1_000_000)
        #expect(SubarraySumsInBand.count(values, low: -5_000_000_000, high: 20_000_000_000) == expected)
        let small = (0..<100_000).map { _ in Int.random(in: -3...3, using: &random) }
        #expect(SubarraySumsInBand.count(small, low: 0, high: 0) == mergeReference(small, 0, 0))
    }
}
