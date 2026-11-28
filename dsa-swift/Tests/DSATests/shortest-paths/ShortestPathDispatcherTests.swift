import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DispatcherRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ShortestPathDispatcherTests {
    typealias Method = ShortestPathDispatcher.Method

    /// The decision table, read from the top, with a three-colour DFS for the cycle question
    private func expectedMethod(_ nodes: Int, _ edges: [[Int]]) -> Method {
        let weights = edges.map { $0[2] }
        if weights.isEmpty || (Set(weights).count == 1 && weights[0] >= 1) { return .bfs }
        if weights.allSatisfy({ $0 == 0 || $0 == 1 }) { return .zeroOneBFS }
        var colour = Array(repeating: 0, count: nodes)                // 0 new, 1 on the path, 2 done
        func hasCycle(from node: Int) -> Bool {
            colour[node] = 1
            for edge in edges where edge[0] == node {
                if colour[edge[1]] == 1 || (colour[edge[1]] == 0 && hasCycle(from: edge[1])) { return true }
            }
            colour[node] = 2
            return false
        }
        if !(0..<nodes).contains(where: { colour[$0] == 0 && hasCycle(from: $0) }) { return .dagOrder }
        return weights.allSatisfy { $0 >= 0 } ? .dijkstra : .bellmanFord
    }

    /// Bellman–Ford with every round run in full: slow, but right for any graph without a negative cycle
    private func reference(_ nodes: Int, _ edges: [[Int]], _ source: Int) -> [Int?] {
        var distance: [Int?] = Array(repeating: nil, count: nodes)
        distance[source] = 0
        for _ in 0..<nodes {
            for edge in edges {
                if let here = distance[edge[0]], here + edge[2] < (distance[edge[1]] ?? Int.max) {
                    distance[edge[1]] = here + edge[2]
                }
            }
        }
        return distance
    }

    private static let lessonDAG = [[0, 1, 3], [0, 2, 6], [1, 2, -4], [1, 3, 2], [2, 3, 1], [3, 4, -2], [2, 4, 5]]

    @Test("Examples and small cases", arguments: [
        (4, [[0, 1, 5], [1, 2, 5], [0, 2, 5], [2, 3, 5]], 0, Method.bfs, [0, 5, 5, 10]),
        (4, [[0, 1, 0], [1, 2, 1], [0, 2, 1], [2, 3, 0], [3, 1, 0]], 0, .zeroOneBFS, [0, 0, 1, 1]),
        (5, lessonDAG, 0, .dagOrder, [0, 3, -1, 0, -2]),
        (3, [[0, 1, 4], [1, 0, 4], [1, 2, 3], [0, 2, 9]], 0, .dijkstra, [0, 4, 7]),
        (3, [[0, 1, 4], [1, 2, -2], [2, 1, 3], [0, 2, 5]], 0, .bellmanFord, [0, 4, 2]),
        (3, [], 1, .bfs, [nil, 0, nil]),
        (2, [[0, 1, 0]], 0, .zeroOneBFS, [0, 0]),                    // all 0: not the BFS row
        (3, [[0, 1, 1], [1, 2, 1], [2, 0, 1]], 0, .bfs, [0, 1, 2]),
        (2, [[0, 0, 3], [0, 1, 2]], 0, .dijkstra, [0, 2]),            // a loop is a cycle
        (3, [[0, 1, 2], [1, 2, 3], [0, 2, 7]], 0, .dagOrder, [0, 2, 5]),   // DAG before Dijkstra
        (2, [[0, 1, 2], [1, 0, 2]], 1, .bfs, [2, 0]),
        (3, [[0, 1, -1], [1, 2, -1]], 0, .dagOrder, [0, -1, -2]),     // equal but negative
        (4, [[0, 1, 4], [1, 0, 2], [2, 3, 1]], 0, .dijkstra, [0, 4, nil, nil]),
        (4, [[1, 2, -3], [2, 1, 5], [0, 1, 2], [3, 0, 1]], 0, .bellmanFord, [0, 2, -1, nil]),
        (1, [], 0, .bfs, [0]),
    ] as [(Int, [[Int]], Int, Method, [Int?])])
    func examples(nodes: Int, edges: [[Int]], source: Int, method: Method, distances: [Int?]) {
        let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: source)
        #expect(result.method == method)
        #expect(result.distances == distances)
    }

    @Test("Matches the decision table and Bellman–Ford on 600 random graphs of every kind")
    func randomSmall() {
        var random = DispatcherRandom(seed: 744)
        for round in 0..<600 {
            let nodes = Int.random(in: 1...8, using: &random)
            let count = Int.random(in: 0...16, using: &random)
            let order = Array(0..<nodes).shuffled(using: &random)
            let potential = (0..<nodes).map { _ in Int.random(in: 0...10, using: &random) }
            let same = Int.random(in: 1...9, using: &random)
            var edges: [[Int]] = []
            for _ in 0..<count {
                var a = Int.random(in: 0..<nodes, using: &random), b = Int.random(in: 0..<nodes, using: &random)
                let weight: Int
                switch round % 5 {
                case 0: weight = same                                             // equal weights
                case 1: weight = Int.random(in: 0...1, using: &random)            // zeros and ones
                case 2:                                                           // a DAG, any weights
                    if a == b { continue }
                    (a, b) = (order[min(a, b)], order[max(a, b)])
                    weight = Int.random(in: -9...9, using: &random)
                case 3: weight = Int.random(in: 0...9, using: &random)            // non-negative
                default:                                                          // negative, no negative cycle
                    weight = Int.random(in: 0...9, using: &random) + potential[a] - potential[b]
                }
                edges.append([a, b, weight])
            }
            let source = Int.random(in: 0..<nodes, using: &random)
            let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: source)
            #expect(result.method == expectedMethod(nodes, edges))
            #expect(result.distances == reference(nodes, edges, source))
        }
    }

    @Test("A DAG of 20,000 nodes with negative weights, listed backwards")
    func largeDAG() {
        // A chain through every node plus forward shortcuts, with the edges listed from the end of the
        // chain to the start. Relaxing them in that order moves information one node per round, so
        // Bellman–Ford would need 20,000 rounds of 100,000 edges.
        var random = DispatcherRandom(seed: 20_000)
        let nodes = 20_000
        let label = Array(0..<nodes).shuffled(using: &random)          // label[i]: the i-th node of the chain
        var byPosition: [(from: Int, to: Int, weight: Int)] = (0..<(nodes - 1)).map { ($0, $0 + 1, Int.random(in: -5...5, using: &random)) }
        while byPosition.count < 100_000 {
            let i = Int.random(in: 0..<(nodes - 1), using: &random)
            let j = Int.random(in: (i + 1)...min(nodes - 1, i + 50), using: &random)
            byPosition.append((i, j, Int.random(in: -20...20, using: &random)))
        }
        byPosition.sort { $0.from > $1.from }
        var best = Array(repeating: Int.max, count: nodes)              // by chain position
        best[0] = 0
        for edge in byPosition.reversed() where best[edge.from] != Int.max {
            best[edge.to] = min(best[edge.to], best[edge.from] + edge.weight)
        }
        let edges = byPosition.map { [label[$0.from], label[$0.to], $0.weight] }
        var expected: [Int?] = Array(repeating: nil, count: nodes)
        for position in 0..<nodes {
            expected[label[position]] = best[position]
        }
        let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: label[0])
        #expect(result.method == .dagOrder)
        #expect(result.distances == expected)
    }

    @Test("30,000 nodes with cycles and non-negative weights, shuffled")
    func largeNonNegative() {
        // A chain with weights 0...9, plus backward edges (cycles) and forward shortcuts that are never
        // cheaper than the chain. So the distances are the chain's running totals.
        var random = DispatcherRandom(seed: 30_000)
        let nodes = 30_000
        let step = (0..<(nodes - 1)).map { _ in Int.random(in: 0...9, using: &random) }
        var total = [0]
        for weight in step { total.append(total.last! + weight) }
        var edges = (0..<(nodes - 1)).map { [$0, $0 + 1, step[$0]] }
        while edges.count < 120_000 {
            let i = Int.random(in: 0..<nodes, using: &random), j = Int.random(in: 0..<nodes, using: &random)
            let extra = Int.random(in: 0...20, using: &random)
            edges.append(i < j ? [i, j, total[j] - total[i] + extra] : [i, j, extra])
        }
        edges.shuffle(using: &random)
        let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: 0)
        #expect(result.method == .dijkstra)
        #expect(result.distances == total.map { Optional($0) })
    }

    @Test("100,000 nodes with weights 0 and 1, and a planted answer")
    func largeZeroOne() {
        // Nodes in a hidden order, each 0 or 1 further than the one before, joined in that order; extra
        // edges never beat the planted distances. 1,000 extra nodes can't be reached.
        var random = DispatcherRandom(seed: 101)
        let nodes = 100_000
        let order = Array(0..<nodes).shuffled(using: &random)
        var target = Array(repeating: 0, count: nodes + 1_000)
        for position in 1..<nodes {
            target[order[position]] = target[order[position - 1]] + Int.random(in: 0...1, using: &random)
        }
        var edges = (1..<nodes).map { [order[$0 - 1], order[$0], target[order[$0]] - target[order[$0 - 1]]] }
        while edges.count < 300_000 {
            let a = Int.random(in: 0..<(nodes + 1_000), using: &random), b = Int.random(in: 0..<nodes, using: &random)
            let gap = target[b] - target[a]
            if gap <= 0 {
                edges.append([a, b, Int.random(in: 0...1, using: &random)])
            } else if gap == 1 {
                edges.append([a, b, 1])
            }
        }
        edges.shuffle(using: &random)
        let result = ShortestPathDispatcher.route(nodes: nodes + 1_000, edges: edges, source: order[0])
        #expect(result.method == .zeroOneBFS)
        #expect(result.distances == target.prefix(nodes).map { Optional($0) } + Array(repeating: nil, count: 1_000))
    }

    @Test("100,000 nodes where every edge costs 7")
    func largeEqual() {
        var random = DispatcherRandom(seed: 7)
        let nodes = 100_000
        let edges = (0..<300_000).map { _ in [Int.random(in: 0..<nodes, using: &random), Int.random(in: 0..<nodes, using: &random), 7] }
        var hops = Array(repeating: -1, count: nodes)
        var next: [[Int]] = Array(repeating: [], count: nodes)
        for edge in edges { next[edge[0]].append(edge[1]) }
        hops[0] = 0
        var queue = [0]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            for to in next[node] where hops[to] == -1 {
                hops[to] = hops[node] + 1
                queue.append(to)
            }
        }
        let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: 0)
        #expect(result.method == .bfs)
        #expect(result.distances == hops.map { $0 == -1 ? nil : $0 * 7 })
    }

    @Test("300 nodes with negative weights and cycles")
    func mediumNegative() {
        // Weight = (a non-negative base) + potential[from] - potential[to]: around any cycle the
        // potentials cancel, so no cycle is negative, but many single edges are.
        var random = DispatcherRandom(seed: 300)
        let nodes = 300
        let potential = (0..<nodes).map { _ in Int.random(in: 0...1_000, using: &random) }
        let edges = (0..<3_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<nodes, using: &random), b = Int.random(in: 0..<nodes, using: &random)
            return [a, b, Int.random(in: 0...100, using: &random) + potential[a] - potential[b]]
        }
        let result = ShortestPathDispatcher.route(nodes: nodes, edges: edges, source: 0)
        #expect(result.method == .bellmanFord)
        #expect(result.distances == reference(nodes, edges, 0))
    }
}
