import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CommuterRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CommuterPassPlannerTests {
    /// Every way of choosing a pass for the first uncovered day, without remembering anything: exponential
    private func byEveryPlan(_ days: [Int], _ passes: [[Int]], from i: Int = 0) -> Int {
        if i == days.count { return 0 }
        var best = Int.max
        for pass in passes {
            var next = i
            while next < days.count, days[next] < days[i] + pass[0] {
                next += 1
            }
            best = min(best, pass[1] + byEveryPlan(days, passes, from: next))
        }
        return best
    }

    /// Bottom-up over the days, finding where each pass ends with a binary search: O(n · p · log n)
    private func byBinarySearch(_ days: [Int], _ passes: [[Int]]) -> Int {
        let n = days.count
        var cost = Array(repeating: 0, count: n + 1)
        for i in stride(from: n - 1, through: 0, by: -1) {
            var best = Int.max
            for pass in passes {
                var low = i
                var high = n                  // the first index whose day is past the pass
                while low < high {
                    let mid = (low + high) / 2
                    if days[mid] < days[i] + pass[0] { low = mid + 1 } else { high = mid }
                }
                best = min(best, pass[1] + cost[low])
            }
            cost[i] = best
        }
        return cost[0]
    }

    private func randomDays(_ count: Int, maxGap: Int, using random: inout CommuterRandom) -> [Int] {
        var day = 0
        return (0..<count).map { _ in
            day += Int.random(in: 1...maxGap, using: &random)
            return day
        }
    }

    @Test("Examples and small cases", arguments: [
        ([1, 2, 3, 4, 5, 9, 20, 21], [[1, 4], [7, 15], [30, 40]], 27),
        ([3, 4, 8, 9, 10, 11, 12, 30], [[1, 4], [7, 15], [30, 40]], 27),
        ([5], [[1, 4], [7, 15]], 4),
        ([1, 2, 6, 7, 8, 12], [[1, 2], [3, 5], [7, 9]], 11),
        ([], [[1, 4]], 0),
        ([1, 2, 3], [[1, 10], [3, 12]], 12),
        ([10, 1_000_000_000], [[1, 5], [1_000_000_000, 7]], 7),
    ] as [([Int], [[Int]], Int)])
    func examples(days: [Int], passes: [[Int]], expected: Int) {
        #expect(CommuterPassPlanner.cheapestCost(travelDays: days, passes: passes) == expected)
    }

    @Test("Matches trying every plan, on 300 small calendars")
    func randomSmall() {
        var random = CommuterRandom(seed: 559)
        for _ in 0..<300 {
            let days = randomDays(Int.random(in: 1...9, using: &random), maxGap: 6, using: &random)
            let passes = (0..<Int.random(in: 1...3, using: &random)).map { _ in
                [Int.random(in: 1...15, using: &random), Int.random(in: 1...30, using: &random)]
            }
            #expect(CommuterPassPlanner.cheapestCost(travelDays: days, passes: passes) == byEveryPlan(days, passes))
        }
    }

    @Test("100,000 travel days")
    func large() {
        var random = CommuterRandom(seed: 2_559)
        for maxGap in [1, 3, 10_000] {
            let days = randomDays(100_000, maxGap: maxGap, using: &random)
            let passes = [[1, 3], [7, 14], [30, 45], [90, 120], [365, 400], [1_000, 1_000]]
            #expect(CommuterPassPlanner.cheapestCost(travelDays: days, passes: passes) == byBinarySearch(days, passes))
        }

        let every = Array(1...100_000)
        #expect(CommuterPassPlanner.cheapestCost(travelDays: every, passes: [[1, 3]]) == 300_000)
        #expect(CommuterPassPlanner.cheapestCost(travelDays: every, passes: [[1, 3], [1_000_000_000, 1_000_000]]) == 300_000)
        #expect(CommuterPassPlanner.cheapestCost(travelDays: every, passes: [[1, 3], [10, 20]]) == 200_000)
    }
}
