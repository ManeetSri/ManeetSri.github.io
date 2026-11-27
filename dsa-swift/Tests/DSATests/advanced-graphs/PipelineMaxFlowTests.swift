import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct FlowRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct PipelineMaxFlowTests {
    private func randomNetwork(stations n: Int, pipes count: Int, maxCapacity: Int, seed: UInt64) -> [[Int]] {
        var random = FlowRandom(state: seed)
        var pipes: [[Int]] = []
        while pipes.count < count {
            let from = random.next(n), to = random.next(n)
            if from == to { continue }
            pipes.append([from, to, 1 + random.next(maxCapacity)])
        }
        return pipes
    }

    @Test("Small networks", arguments: [
        // The lesson's network: the cut A→C plus B→D (6 + 8) is the bottleneck
        (6, [[0, 1, 7], [0, 2, 9], [1, 2, 3], [1, 3, 6], [2, 4, 8], [4, 3, 2], [3, 5, 8], [4, 5, 7]], 0, 5, 14),
        // Needs a backward edge: the path 0→1→2→3 must be partly undone
        (4, [[0, 1, 1], [0, 2, 1], [1, 2, 1], [1, 3, 1], [2, 3, 1]], 0, 3, 2),
        (3, [[0, 1, 3], [0, 1, 4], [1, 2, 5]], 0, 2, 5),
        (3, [[0, 1, 10], [1, 0, 5], [1, 2, 7]], 0, 2, 7),
        (4, [[0, 1, 5], [2, 3, 5]], 0, 3, 0),
        (3, [[0, 1, 0], [1, 2, 9]], 0, 2, 0),
        (2, [], 0, 1, 0),
        (2, [[1, 0, 8]], 0, 1, 0),
        (4, [[3, 2, 4], [2, 1, 6], [3, 1, 3], [1, 0, 9]], 3, 0, 7),
    ] as [(Int, [[Int]], Int, Int, Int)])
    func smallNetworks(n: Int, pipes: [[Int]], source: Int, sink: Int, expected: Int) {
        #expect(PipelineMaxFlow.maxFlow(n, pipes, from: source, to: sink) == expected)
    }

    @Test("Huge capacities don't slow it down")
    func hugeCapacities() {
        // With unlucky path choices, plain Ford–Fulkerson would push 1 unit at a time across 1→2
        let big = 1_000_000_000
        let pipes = [[0, 1, big], [0, 2, big], [1, 2, 1], [1, 3, big], [2, 3, big]]
        #expect(PipelineMaxFlow.maxFlow(4, pipes, from: 0, to: 3) == 2 * big)
    }

    @Test("A random network: 300 stations, 3,000 pipes")
    func randomSparse() {
        let pipes = randomNetwork(stations: 300, pipes: 3_000, maxCapacity: 100, seed: 47)
        #expect(PipelineMaxFlow.maxFlow(300, pipes, from: 0, to: 299) == 359)
    }

    @Test("A layered network: 150 + 150 stations")
    func layeredNetwork() {
        var random = FlowRandom(state: 2_024)
        var pipes: [[Int]] = []
        for a in 1...150 { pipes.append([0, a, 1 + random.next(50)]) }
        for a in 1...150 {
            for _ in 0..<8 { pipes.append([a, 151 + random.next(150), 1 + random.next(30)]) }
        }
        for b in 151...300 { pipes.append([b, 301, 1 + random.next(50)]) }
        #expect(PipelineMaxFlow.maxFlow(302, pipes, from: 0, to: 301) == 3_700)
    }

    @Test("Unit pipes: 400 stations, about 4,200 pipes")
    func unitNetwork() {
        var pipes = randomNetwork(stations: 400, pipes: 4_000, maxCapacity: 1, seed: 7)
        for station in 1...100 { pipes.append([0, station, 1]) }
        for station in 300..<399 { pipes.append([station, 399, 1]) }
        #expect(PipelineMaxFlow.maxFlow(400, pipes, from: 0, to: 399) == 103)
    }

    @Test("Wide and shallow: 200 parallel routes")
    func parallelRoutes() {
        // Route i is source → i → sink with capacities i and 201 - i: it carries min(i, 201 - i)
        let pipes = (1...200).flatMap { [[0, $0, $0], [$0, 201, 201 - $0]] }
        let expected = (1...200).reduce(0) { $0 + min($1, 201 - $1) }
        #expect(PipelineMaxFlow.maxFlow(202, pipes, from: 0, to: 201) == expected)
    }
}
