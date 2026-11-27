import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct JobsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DeadlineJobProfitsTests {
    /// Tries every subset of jobs. A subset fits when, sorted by deadline, the i-th job (from 1) has a
    /// deadline of at least i: doing them in deadline order is never worse than any other order.
    private func exhaustive(_ jobs: [[Int]]) -> Int {
        var best = 0
        for mask in 0..<(1 << jobs.count) {
            let chosen = jobs.indices.filter { mask & (1 << $0) != 0 }.map { jobs[$0] }
            let deadlines = chosen.map { $0[0] }.sorted()
            if deadlines.indices.allSatisfy({ deadlines[$0] >= $0 + 1 }) {
                best = max(best, chosen.reduce(0) { $0 + $1[1] })
            }
        }
        return best
    }

    /// A different greedy: by deadline, keeping the accepted profits in a min-heap and dropping the
    /// smallest whenever more jobs are accepted than the current deadline allows. O(n log n).
    private func byDeadline(_ jobs: [[Int]]) -> Int {
        var accepted = Heap<Int>.minHeap()
        for job in jobs.sorted(by: { $0[0] < $1[0] }) {
            accepted.insert(job[1])
            if accepted.count > job[0] { accepted.pop() }
        }
        return accepted.unordered.reduce(0, +)
    }

    @Test("Examples and small cases", arguments: [
        ([[2, 40], [1, 25], [3, 30], [1, 35], [3, 10], [2, 20]], 105),
        ([[1, 10], [2, 50], [2, 30], [1, 40]], 90),
        ([[1_000_000_000, 5], [1, 7], [1, 3]], 12),
        ([], 0),
        ([[1, 9]], 9),
        ([[1, 4], [1, 8], [1, 6]], 8),
        ([[3, 1], [3, 2], [3, 3], [3, 4]], 9),
        ([[2, 5], [2, 5], [1, 5]], 10),
        ([[4, 20], [1, 10], [1, 40], [1, 30]], 60),
    ] as [([[Int]], Int)])
    func examples(jobs: [[Int]], expected: Int) {
        #expect(DeadlineJobProfits.maxProfit(jobs) == expected)
    }

    @Test("Matches trying every subset on 500 small random job lists")
    func randomSmall() {
        var random = JobsRandom(seed: 50)
        for _ in 0..<500 {
            let jobs = (0..<Int.random(in: 0...9, using: &random)).map { _ in
                [Int.random(in: 1...5, using: &random), Int.random(in: 1...20, using: &random)]
            }
            #expect(DeadlineJobProfits.maxProfit(jobs) == exhaustive(jobs), "jobs \(jobs)")
        }
    }

    @Test("100,000 jobs with deadlines up to a billion")
    func large() {
        var random = JobsRandom(seed: 2_026)
        let n = 100_000
        let tight = (0..<n).map { _ in [Int.random(in: 1...50_000, using: &random), Int.random(in: 1...1_000_000, using: &random)] }
        #expect(DeadlineJobProfits.maxProfit(tight) == byDeadline(tight))

        let loose = (0..<n).map { _ in [Int.random(in: 1...1_000_000_000, using: &random), Int.random(in: 1...1_000_000, using: &random)] }
        #expect(DeadlineJobProfits.maxProfit(loose) == byDeadline(loose))

        // Deadlines of at least n: everything fits
        let roomy = (0..<n).map { i in [n + i, i + 1] }
        #expect(DeadlineJobProfits.maxProfit(roomy) == n * (n + 1) / 2)

        // Everything due in hour 1: only the best job counts
        let rush = (0..<n).map { i in [1, (i * 7_919) % 999_983 + 1] }
        #expect(DeadlineJobProfits.maxProfit(rush) == rush.map { $0[1] }.max()!)
    }
}
