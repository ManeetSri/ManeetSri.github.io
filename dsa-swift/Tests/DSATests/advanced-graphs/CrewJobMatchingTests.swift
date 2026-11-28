import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct CrewRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct CrewJobMatchingTests {
    /// Checks the assignment's shape and rules, and returns how many workers got a job (or -1 if broken).
    private func assignedCount(_ assignment: [Int], workers: Int, jobs: Int, canDo: [[Int]]) -> Int {
        guard assignment.count == workers else { return -1 }
        var taken = Set<Int>()
        for (worker, job) in assignment.enumerated() where job != -1 {
            guard canDo[worker].contains(job), taken.insert(job).inserted else { return -1 }
        }
        return taken.count
    }

    /// Tries every choice for every worker: exponential, so only for a handful of workers.
    private func bruteForce(workers: Int, jobs: Int, canDo: [[Int]]) -> Int {
        var taken = [Bool](repeating: false, count: jobs)
        func best(from worker: Int) -> Int {
            if worker == workers { return 0 }
            var result = best(from: worker + 1)                // this worker gets nothing
            for job in canDo[worker] where !taken[job] {
                taken[job] = true
                result = max(result, 1 + best(from: worker + 1))
                taken[job] = false
            }
            return result
        }
        return best(from: 0)
    }

    @Test("Small crews", arguments: [
        (2, 2, [[0, 1], [0]], 2),
        (3, 2, [[0], [0, 1], [1]], 2),
        (3, 3, [[], [], []], 0),
        (4, 4, [[0, 1], [0], [2, 3], [2]], 4),
        (3, 4, [[3], [3], [3]], 1),
        (4, 3, [[0, 1, 2], [0], [1], [0, 1]], 3),
        (1, 1, [[0]], 1),
        (5, 5, [[0, 1], [1, 2], [2, 3], [3, 4], [0]], 5),
    ] as [(Int, Int, [[Int]], Int)])
    func smallCrews(workers: Int, jobs: Int, canDo: [[Int]], expected: Int) {
        let assignment = CrewJobMatching.assign(workers: workers, jobs: jobs, canDo: canDo)
        #expect(assignedCount(assignment, workers: workers, jobs: jobs, canDo: canDo) == expected)
    }

    @Test("Matches brute force on 300 random small crews")
    func randomSmall() {
        var random = CrewRandom(state: 5)
        for _ in 0..<300 {
            let workers = 1 + random.next(6), jobs = 1 + random.next(6)
            let canDo = (0..<workers).map { _ in (0..<random.next(4)).map { _ in random.next(jobs) } }
            let assignment = CrewJobMatching.assign(workers: workers, jobs: jobs, canDo: canDo)
            #expect(assignedCount(assignment, workers: workers, jobs: jobs, canDo: canDo)
                    == bruteForce(workers: workers, jobs: jobs, canDo: canDo))
        }
    }

    @Test("Everyone moves along for the last worker: 300 workers")
    func longReassignment() {
        // Worker w can do jobs w and w + 1, and the last worker only job 0. Handing out the first
        // choices leaves the last worker stuck until every other worker shifts up by one job.
        let n = 300
        let canDo = (0..<(n - 1)).map { [$0, $0 + 1] } + [[0]]
        let assignment = CrewJobMatching.assign(workers: n, jobs: n, canDo: canDo)
        #expect(assignedCount(assignment, workers: n, jobs: n, canDo: canDo) == n)
    }

    @Test("400 workers with a hidden perfect assignment among 10 options each")
    func hiddenPerfect() {
        var random = CrewRandom(state: 400)
        let n = 400
        var secret = Array(0..<n)
        for i in stride(from: n - 1, to: 0, by: -1) { secret.swapAt(i, random.next(i + 1)) }
        let canDo = (0..<n).map { worker in
            var options = (0..<9).map { _ in random.next(n) } + [secret[worker]]
            options.swapAt(9, random.next(10))
            return options
        }
        let assignment = CrewJobMatching.assign(workers: n, jobs: n, canDo: canDo)
        #expect(assignedCount(assignment, workers: n, jobs: n, canDo: canDo) == n)
    }

    @Test("40 teams that can't share jobs")
    func teams() {
        // Team t has some workers, each qualified for every job in the team's own pool, so team t
        // contributes min(workers, jobs) to the best assignment
        var random = CrewRandom(state: 40)
        var canDo: [[Int]] = []
        var jobs = 0
        var expected = 0
        for _ in 0..<40 {
            let teamWorkers = 1 + random.next(12), teamJobs = 1 + random.next(12)
            let pool = Array(jobs..<(jobs + teamJobs))
            for _ in 0..<teamWorkers { canDo.append(pool.reversed()) }
            jobs += teamJobs
            expected += min(teamWorkers, teamJobs)
        }
        let assignment = CrewJobMatching.assign(workers: canDo.count, jobs: jobs, canDo: canDo)
        #expect(assignedCount(assignment, workers: canDo.count, jobs: jobs, canDo: canDo) == expected)
    }
}
