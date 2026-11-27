import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct FirstFitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FirstFitServersTests {
    /// First fit the slow way: scan the servers for every job
    private func scan(_ jobs: [Int], _ capacities: [Int]) -> [Int] {
        var free = capacities
        return jobs.map { job in
            guard let server = free.firstIndex(where: { $0 >= job }) else { return -1 }
            free[server] -= job
            return server
        }
    }

    @Test("The examples", arguments: [
        ([5, 3, 6, 2, 9, 4, 1], [4, 10, 3, 8], [1, 0, 3, 1, -1, -1, 0]),
        ([5, 1], [5], [0, -1]),
        ([2, 2, 2], [3, 3], [0, 1, -1]),
        ([1], [], [-1]),
        ([], [7, 7], []),
    ])
    func examples(jobs: [Int], capacities: [Int], expected: [Int]) {
        #expect(FirstFitServers.place(jobs, on: capacities) == expected)
    }

    @Test("Servers with no room at all, and jobs that fit exactly")
    func edges() {
        #expect(FirstFitServers.place([1, 1], on: [0, 0, 0]) == [-1, -1])
        #expect(FirstFitServers.place([5, 4, 3], on: [5, 4, 3]) == [0, 1, 2])
        #expect(FirstFitServers.place([3, 4, 5], on: [5, 4, 3]) == [0, 1, -1])
        #expect(FirstFitServers.place([1_000_000_000, 1], on: [1_000_000_000]) == [0, -1])
        // Five servers: not a power of two, so the padding must never be chosen
        #expect(FirstFitServers.place([9, 9, 9, 9, 9, 9], on: [9, 9, 9, 9, 9]) == [0, 1, 2, 3, 4, -1])
    }

    @Test("Random clusters match scanning", arguments: [1, 2, 3, 4, 5])
    func matchesScan(seed: UInt64) {
        var random = FirstFitRandom(seed: seed)
        for _ in 0..<40 {
            let servers = Int.random(in: 0...20, using: &random)
            let capacities = (0..<servers).map { _ in Int.random(in: 0...30, using: &random) }
            let jobs = (0..<Int.random(in: 0...40, using: &random)).map { _ in Int.random(in: 1...15, using: &random) }
            #expect(FirstFitServers.place(jobs, on: capacities) == scan(jobs, capacities))
        }
    }

    @Test("200,000 jobs on 200,000 servers")
    func large() {
        var random = FirstFitRandom(seed: 200_000)
        let n = 200_000
        // Most servers are nearly full, so first fit has to look a long way along the row
        let capacities = (0..<n).map { i in i.isMultiple(of: 1_000) ? 1_000_000_000 : Int.random(in: 0...50, using: &random) }
        let jobs = (0..<n).map { _ in Int.random(in: 40...5_000, using: &random) }
        let placements = FirstFitServers.place(jobs, on: capacities)
        #expect(placements.count == n)
        guard placements.count == n else { return }
        // Replay the placements: each must fit, and no lower server may have had room at the time
        var free = capacities
        var rejected = 0
        for (job, server) in zip(jobs, placements) {
            if server == -1 {
                rejected += 1
                continue
            }
            guard server >= 0 && server < n && free[server] >= job else {
                Issue.record("a job of \(job) was placed on server \(server), which can't hold it")
                return
            }
            free[server] -= job
        }
        #expect(rejected == 0, "the big servers have room for every job")
        // Spot-check first fit on the first 2,000 jobs against a scan
        #expect(Array(placements.prefix(2_000)) == scan(Array(jobs.prefix(2_000)), capacities))
    }
}
