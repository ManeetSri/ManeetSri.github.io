import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct AuditionRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct SecretaryCutoffPlannerTests {
    /// The plan, written independently: the first index from r on that beats everything before it
    private func plan(_ scores: [Int], _ r: Int) -> Int? {
        var best = Int.min
        for (i, score) in scores.enumerated() {
            if i >= r && score > best { return i }
            best = max(best, score)
        }
        return nil
    }

    /// For each r, how many of the n! orders of the scores 0..<n end with the best singer cast
    private func successCounts(_ n: Int) -> [Int] {
        var counts = Array(repeating: 0, count: n + 1)
        var order = Array(0..<n)
        func permute(_ k: Int) {
            if k == n {
                for r in 0...n {
                    if let cast = plan(order, r), order[cast] == n - 1 { counts[r] += 1 }
                }
                return
            }
            for i in k..<n {
                order.swapAt(k, i)
                permute(k + 1)
                order.swapAt(k, i)
            }
        }
        permute(0)
        return counts
    }

    @Test("The examples")
    func examples() {
        #expect(SecretaryCutoffPlanner.hire(scores: [3, 7, 2, 9, 8], watch: 2) == 3)
        #expect(SecretaryCutoffPlanner.hire(scores: [3, 7, 2, 9, 8], watch: 0) == 0)
        #expect(SecretaryCutoffPlanner.hire(scores: [9, 7, 2, 3], watch: 1) == nil)
        #expect(abs(SecretaryCutoffPlanner.successChance(candidates: 3, watch: 1) - 0.5) < 1e-12)
        #expect(abs(SecretaryCutoffPlanner.successChance(candidates: 4, watch: 1) - 11.0 / 24.0) < 1e-12)
        #expect(SecretaryCutoffPlanner.successChance(candidates: 5, watch: 5) == 0)
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: 3) == 1)
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: 2) == 0)
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: 100) == 37)
    }

    @Test("Hiring edge cases")
    func hireEdges() {
        #expect(SecretaryCutoffPlanner.hire(scores: [], watch: 0) == nil)
        #expect(SecretaryCutoffPlanner.hire(scores: [5], watch: 0) == 0)
        #expect(SecretaryCutoffPlanner.hire(scores: [5], watch: 1) == nil)
        #expect(SecretaryCutoffPlanner.hire(scores: [1, 2, 3, 4], watch: 4) == nil)
        #expect(SecretaryCutoffPlanner.hire(scores: [1, 2, 3, 4], watch: 3) == 3)
        #expect(SecretaryCutoffPlanner.hire(scores: [-5, -9, -1], watch: 1) == 2)
    }

    @Test("Chances match trying every arrival order, up to 8 singers")
    func bruteForce() {
        var factorial = 1
        for n in 1...8 {
            factorial *= n
            let counts = successCounts(n)
            for r in 0...n {
                let chance = SecretaryCutoffPlanner.successChance(candidates: n, watch: r)
                #expect(abs(chance - Double(counts[r]) / Double(factorial)) < 1e-12, "n = \(n), r = \(r)")
            }
            let best = counts.indices.max { counts[$0] < counts[$1] || (counts[$0] == counts[$1] && $0 > $1) }
            #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: n) == best, "n = \(n)")
        }
    }

    @Test("Best watch counts", arguments: [
        (1, 0), (2, 0), (3, 1), (4, 1), (5, 2), (6, 2), (7, 2), (8, 3), (10, 3), (20, 7), (100, 37),
        (1_000, 368), (12_345, 4_541), (50_000, 18_394),
    ])
    func bestCounts(n: Int, expected: Int) {
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: n) == expected)
    }

    @Test("Random auditions match the plan")
    func randomHires() {
        var random = AuditionRandom(seed: 37)
        for _ in 0..<300 {
            let n = Int.random(in: 0...30, using: &random)
            let scores = Array(0..<n).map { $0 * 3 - 20 }.shuffled(using: &random)
            let r = Int.random(in: 0...n, using: &random)
            #expect(SecretaryCutoffPlanner.hire(scores: scores, watch: r) == plan(scores, r), "scores \(scores), watch \(r)")
        }
    }

    @Test("A million singers: watch about n / e, succeed about 1 / e of the time")
    func large() {
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: 1_000_000) == 367_879)
        #expect(SecretaryCutoffPlanner.bestWatchCount(candidates: 999_983) == 367_873)
        let chance = SecretaryCutoffPlanner.successChance(candidates: 1_000_000, watch: 367_879)
        #expect(abs(chance - 0.367_879_757_231_873_66) < 1e-9)
        #expect(abs(SecretaryCutoffPlanner.successChance(candidates: 100, watch: 37) - 0.371_042_778_712_643_03) < 1e-12)
        // A long audition, checked against the plan
        var random = AuditionRandom(seed: 1_000_000)
        let scores = Array(0..<100_000).shuffled(using: &random)
        #expect(SecretaryCutoffPlanner.hire(scores: scores, watch: 36_788) == plan(scores, 36_788))
    }
}
