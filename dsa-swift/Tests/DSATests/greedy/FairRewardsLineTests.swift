import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RewardsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FairRewardsLineTests {
    /// Tries every handout of 1...n rewards per child (no child ever needs more than n) and keeps the
    /// cheapest valid one. Exponential, so only for very short lines.
    private func exhaustive(_ ratings: [Int]) -> Int {
        let n = ratings.count
        var rewards = Array(repeating: 1, count: n)
        var best = Int.max
        func place(_ i: Int) {
            if i == n {
                best = min(best, rewards.reduce(0, +))
                return
            }
            for amount in 1...n {
                rewards[i] = amount
                // Check the rule with the left neighbour now; the right one is checked when it's placed
                if i > 0 && ratings[i] > ratings[i - 1] && amount <= rewards[i - 1] { continue }
                if i > 0 && ratings[i - 1] > ratings[i] && rewards[i - 1] <= amount { continue }
                place(i + 1)
            }
        }
        place(0)
        return best
    }

    /// Starts everyone at 1 and fixes broken rules until none are left: the least fixed point,
    /// so the minimum. O(n²) in the worst case.
    private func relaxed(_ ratings: [Int]) -> Int {
        var rewards = Array(repeating: 1, count: ratings.count)
        var changed = true
        while changed {
            changed = false
            for i in ratings.indices {
                if i > 0 && ratings[i] > ratings[i - 1] && rewards[i] <= rewards[i - 1] {
                    rewards[i] = rewards[i - 1] + 1
                    changed = true
                }
                if i + 1 < ratings.count && ratings[i] > ratings[i + 1] && rewards[i] <= rewards[i + 1] {
                    rewards[i] = rewards[i + 1] + 1
                    changed = true
                }
            }
        }
        return rewards.reduce(0, +)
    }

    @Test("Examples and small cases", arguments: [
        ([2, 4, 3, 2, 1, 3, 3], 14),
        ([1, 3, 2, 1], 7),
        ([1, 2, 2], 4),
        ([7], 1),
        ([3, 3, 3], 3),
        ([1, 2, 3, 4], 10),
        ([4, 3, 2, 1], 10),
        ([1, 3, 5, 3, 1], 9),
        ([5, 3, 1, 3, 5], 11),
        ([1, 2, 1, 2, 1], 7),
        ([1, 6, 10, 8, 7, 3, 2], 18),
        ([0, 1_000_000_000], 3),
    ] as [([Int], Int)])
    func examples(ratings: [Int], expected: Int) {
        #expect(FairRewardsLine.fewestRewards(ratings) == expected)
    }

    @Test("Matches an exhaustive search on 300 short random lines")
    func randomShort() {
        var random = RewardsRandom(seed: 50)
        for _ in 0..<300 {
            let ratings = (0..<Int.random(in: 1...6, using: &random)).map { _ in Int.random(in: 1...4, using: &random) }
            #expect(FairRewardsLine.fewestRewards(ratings) == exhaustive(ratings), "ratings \(ratings)")
        }
    }

    @Test("Matches fixing rules one by one on 300 longer random lines")
    func randomMedium() {
        var random = RewardsRandom(seed: 51)
        for _ in 0..<300 {
            let ratings = (0..<Int.random(in: 1...80, using: &random)).map { _ in Int.random(in: 1...20, using: &random) }
            #expect(FairRewardsLine.fewestRewards(ratings) == relaxed(ratings), "ratings \(ratings)")
        }
    }

    @Test("100,000 children in long slopes")
    func large() {
        let n = 100_000
        let rising = Array(1...n)
        #expect(FairRewardsLine.fewestRewards(rising) == n * (n + 1) / 2)
        #expect(FairRewardsLine.fewestRewards(rising.reversed()) == n * (n + 1) / 2)
        #expect(FairRewardsLine.fewestRewards(Array(repeating: 42, count: n)) == n)

        // Up from 0 to a peak of 50,000, then down to 1: the climb needs 1, 2, ..., 50,001 (the peak
        // included), and the descent of 49,999 children needs 49,999, ..., 2, 1
        let half = n / 2
        let mountain = Array(0...half) + (1..<half).reversed()
        #expect(mountain.count == n)
        #expect(FairRewardsLine.fewestRewards(mountain) == (half + 1) * (half + 2) / 2 + (half - 1) * half / 2)

        // Alternating low, high: every high child needs 2
        let zigzag = (0..<n).map { $0 % 2 }
        #expect(FairRewardsLine.fewestRewards(zigzag) == n + n / 2)
    }
}
