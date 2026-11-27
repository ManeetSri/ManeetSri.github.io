import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct FrontierRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FrontierParallelBFSTests {
    /// Plain sequential BFS with a head-index queue, to compare against
    private func sequential(_ graph: [[Int]], _ source: Int) -> [Int] {
        var distance = Array(repeating: -1, count: graph.count)
        distance[source] = 0
        var queue = [source]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            for next in graph[node] where distance[next] == -1 {
                distance[next] = distance[node] + 1
                queue.append(next)
            }
        }
        return distance
    }

    private func randomGraph(nodes: Int, edges: Int, using random: inout FrontierRandom) -> [[Int]] {
        var graph = Array(repeating: [Int](), count: nodes)
        for _ in 0..<edges {
            graph[Int.random(in: 0..<nodes, using: &random)].append(Int.random(in: 0..<nodes, using: &random))
        }
        return graph
    }

    @Test("The examples", arguments: [1, 2, 64])
    func examples(chunkSize: Int) async {
        let graph = [[1, 2], [3], [3, 4], [5], [5], [], [0]]
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 0, chunkSize: chunkSize) == [0, 1, 1, 2, 2, 3, -1])
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 6, chunkSize: chunkSize) == [1, 2, 2, 3, 3, 4, 0])
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 5, chunkSize: chunkSize) == [-1, -1, -1, -1, -1, 0, -1])
    }

    @Test("A single node, self-loops and repeated edges")
    func edgeCases() async {
        #expect(await FrontierParallelBFS.distances(graph: [[]], source: 0, chunkSize: 1) == [0])
        #expect(await FrontierParallelBFS.distances(graph: [[0, 0]], source: 0, chunkSize: 3) == [0])
        let graph = [[1, 1, 1, 0], [2, 2], [1, 0], []]
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 0, chunkSize: 1) == [0, 1, 2, -1])
    }

    @Test("Matches sequential BFS on 300 small random graphs")
    func randomSmall() async {
        var random = FrontierRandom(seed: 700)
        for _ in 0..<300 {
            let nodes = Int.random(in: 1...12, using: &random)
            let graph = randomGraph(nodes: nodes, edges: Int.random(in: 0...30, using: &random), using: &random)
            let source = Int.random(in: 0..<nodes, using: &random)
            let chunkSize = Int.random(in: 1...4, using: &random)
            #expect(await FrontierParallelBFS.distances(graph: graph, source: source, chunkSize: chunkSize) == sequential(graph, source))
        }
    }

    @Test("20,000 nodes and 100,000 edges", arguments: [1, 256])
    func large(chunkSize: Int) async {
        var random = FrontierRandom(seed: 70_000)
        let graph = randomGraph(nodes: 20_000, edges: 100_000, using: &random)
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 0, chunkSize: chunkSize) == sequential(graph, 0))
    }

    @Test("A path of 5,000 nodes: one node per level")
    func path() async {
        let graph = (0..<5_000).map { $0 + 1 < 5_000 ? [$0 + 1] : [] }
        #expect(await FrontierParallelBFS.distances(graph: graph, source: 0, chunkSize: 8) == Array(0..<5_000))
    }
}
