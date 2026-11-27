import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PracticeLogRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PracticeLogStretchTests {
    /// Every stretch, scored as it grows: O(n²), clearly right
    private func byEveryStretch(_ minutes: [Int], _ goal: Int) -> Int {
        var best = 0
        for start in minutes.indices {
            var score = 0
            for end in start..<minutes.count {
                score += minutes[end] >= goal ? 1 : -1
                if score > 0 { best = max(best, end - start + 1) }
            }
        }
        return best
    }

    /// A different O(n log n) method: for each end, binary search the record lows of the prefix sums for
    /// the earliest start whose prefix is smaller
    private func byRecordLows(_ minutes: [Int], _ goal: Int) -> Int {
        var prefix = [0]
        for value in minutes {
            prefix.append(prefix.last! + (value >= goal ? 1 : -1))
        }
        var lows: [Int] = [0]              // indexes where the prefix sets a new low, values falling
        for i in 1..<prefix.count where prefix[i] < prefix[lows.last!] {
            lows.append(i)
        }
        var best = 0
        for end in 1..<prefix.count {
            // The first record low whose value is below prefix[end]
            var low = 0
            var high = lows.count
            while low < high {
                let mid = (low + high) / 2
                if prefix[lows[mid]] < prefix[end] { high = mid } else { low = mid + 1 }
            }
            if low < lows.count, lows[low] < end {
                best = max(best, end - lows[low])
            }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([10, 45, 10, 10, 50, 40, 10, 10, 10], 30, 5),
        ([40, 10, 35, 50, 5, 5, 60], 30, 7),
        ([5, 5, 5], 30, 0),
        ([30], 30, 1),
        ([], 30, 0),
        ([0, 0, 45, 0, 0, 60, 60, 0, 0, 0], 30, 5),
        ([1, 0, 1, 0], 1, 3),
        ([0, 0, 0, 1], 1, 1),
        ([7, 7, 7, 7], 0, 4),
    ] as [([Int], Int, Int)])
    func examples(minutes: [Int], goal: Int, expected: Int) {
        #expect(PracticeLogStretch.longestStretch(minutes: minutes, goal: goal) == expected)
    }

    @Test("Matches checking every stretch, on 500 random logs")
    func randomSmall() {
        var random = PracticeLogRandom(seed: 159)
        for _ in 0..<500 {
            let n = Int.random(in: 0...40, using: &random)
            let goal = Int.random(in: 0...60, using: &random)
            let minutes = (0..<n).map { _ in Int.random(in: 0...60, using: &random) }
            #expect(PracticeLogStretch.longestStretch(minutes: minutes, goal: goal) == byEveryStretch(minutes, goal))
        }
    }

    @Test("200,000 days")
    func large() {
        var random = PracticeLogRandom(seed: 2_159)
        let n = 200_000
        // Hit rates just below, at and above a half make the answer short, long and nearly everything
        for rate in [45, 50, 55] {
            let minutes = (0..<n).map { _ in Int.random(in: 0..<100, using: &random) < rate ? 60 : 0 }
            #expect(PracticeLogStretch.longestStretch(minutes: minutes, goal: 30) == byRecordLows(minutes, 30))
        }

        #expect(PracticeLogStretch.longestStretch(minutes: Array(repeating: 90, count: n), goal: 30) == n)
        #expect(PracticeLogStretch.longestStretch(minutes: Array(repeating: 10, count: n), goal: 30) == 0)

        // On, off, on, off, …: the whole log ties, so the best drops one day at the end
        let alternating = (0..<n).map { $0 % 2 == 0 ? 45 : 15 }
        #expect(PracticeLogStretch.longestStretch(minutes: alternating, goal: 30) == n - 1)
    }
}
