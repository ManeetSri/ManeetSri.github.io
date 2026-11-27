import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TrailDaySplitTests {
    /// A tiny deterministic generator, so the random-looking tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Tries every way to split stages[start...] into exactly `days` non-empty days.
    private func bruteForce(_ stages: [Int], from start: Int, days: Int) -> Int {
        if days == 1 { return stages[start...].reduce(0, +) }
        var best = Int.max
        var today = 0
        // Today ends at `end`; leave at least one stage for each remaining day
        for end in start...(stages.count - days) {
            today += stages[end]
            best = min(best, max(today, bruteForce(stages, from: end + 1, days: days - 1)))
        }
        return best
    }

    /// Fewest days needed when no day may exceed `limit`, or nil if some stage is longer than it.
    private func fewestDays(_ stages: [Int], limit: Int) -> Int? {
        var days = 1
        var today = 0
        for length in stages {
            if length > limit { return nil }
            if today + length > limit {
                days += 1
                today = 0
            }
            today += length
        }
        return days
    }

    @Test("Finds the shortest longest day in the examples", arguments: [
        ([12, 5, 7, 10, 3, 9], 3, 17),
        ([12, 5, 7, 10, 3, 9], 2, 24),
        ([12, 5, 7, 10, 3, 9], 6, 12),
        ([12, 5, 7, 10, 3, 9], 1, 46),
        ([4, 9, 3, 7, 2, 8], 3, 13),
        ([1, 1, 1, 1, 20], 2, 20),
        ([8], 1, 8),
    ])
    func examples(stages: [Int], days: Int, expected: Int) {
        #expect(TrailDaySplit.shortestLongestDay(stages: stages, days: days) == expected)
    }

    @Test("Returns -1 when there are fewer stages than days")
    func tooFewStages() {
        #expect(TrailDaySplit.shortestLongestDay(stages: [12, 5, 7, 10, 3, 9], days: 7) == -1)
        #expect(TrailDaySplit.shortestLongestDay(stages: [3], days: 2) == -1)
    }

    @Test("Every day walks at least one stage")
    func everyDayWalks() {
        // The greedy plan fits in one day, but three days are required: each gets one stage
        #expect(TrailDaySplit.shortestLongestDay(stages: [2, 2, 2], days: 3) == 2)
        #expect(TrailDaySplit.shortestLongestDay(stages: [1, 1, 1, 1], days: 3) == 2)
    }

    @Test("Matches trying every split on many small trails")
    func matchesBruteForce() {
        var steps = Steps(seed: 31)
        var firstMismatch: String? = nil
        for _ in 0..<300 {
            let stages = (0..<(steps.next(below: 8) + 1)).map { _ in steps.next(below: 15) + 1 }
            let days = steps.next(below: stages.count) + 1
            let expected = bruteForce(stages, from: 0, days: days)
            if TrailDaySplit.shortestLongestDay(stages: stages, days: days) != expected {
                firstMismatch = firstMismatch ?? "\(stages) in \(days) days"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 stages of up to a billion each")
    func large() {
        var steps = Steps(seed: 1_729)
        let stages = (0..<100_000).map { _ in steps.next(below: 1_000_000_000) + 1 }
        for days in [1, 2, 50, 9_999, 100_000] {
            let longest = TrailDaySplit.shortestLongestDay(stages: stages, days: days)
            #expect(longest >= 1)
            guard longest >= 1 else { continue }
            // Achievable: the greedy plan uses at most `days` days (and there are enough stages to fill the rest)
            #expect((fewestDays(stages, limit: longest) ?? Int.max) <= days, "\(longest) should be achievable")
            #expect((fewestDays(stages, limit: longest - 1) ?? Int.max) > days, "\(longest - 1) should be impossible")
        }
    }
}
