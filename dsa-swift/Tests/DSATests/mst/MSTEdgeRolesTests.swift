import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MSTEdgeRolesTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The answer straight from the definition: list every spanning tree, keep the lightest ones,
    /// and see which edges are in all of them and which in only some.
    private func model(_ n: Int, _ edges: [[Int]]) -> (critical: [Int], pseudoCritical: [Int]) {
        var best = Int.max
        var minimumTrees: [[Int]] = []
        func isSpanningTree(_ chosen: [Int]) -> Bool {
            var parent = Array(0..<n)
            func root(_ x: Int) -> Int {
                var x = x
                while parent[x] != x { x = parent[x] }
                return x
            }
            for index in chosen {
                let a = root(edges[index][0])
                let b = root(edges[index][1])
                if a == b { return false }
                parent[a] = b
            }
            return true
        }
        func choose(from start: Int, _ chosen: inout [Int]) {
            if chosen.count == n - 1 {
                guard isSpanningTree(chosen) else { return }
                let weight = chosen.reduce(0) { $0 + edges[$1][2] }
                if weight < best {
                    best = weight
                    minimumTrees = [chosen]
                } else if weight == best {
                    minimumTrees.append(chosen)
                }
                return
            }
            guard start < edges.count else { return }
            for index in start..<edges.count {
                chosen.append(index)
                choose(from: index + 1, &chosen)
                chosen.removeLast()
            }
        }
        var chosen: [Int] = []
        choose(from: 0, &chosen)
        let uses = edges.indices.map { index in minimumTrees.filter { $0.contains(index) }.count }
        return (edges.indices.filter { uses[$0] == minimumTrees.count },
                edges.indices.filter { uses[$0] > 0 && uses[$0] < minimumTrees.count })
    }

    @Test("The example from the statement")
    func example() {
        let edges = [[0, 1, 1], [1, 2, 1], [2, 3, 2], [0, 3, 2], [0, 2, 3]]
        let roles = MSTEdgeRoles.classify(4, edges)
        #expect(roles.critical == [0, 1])
        #expect(roles.pseudoCritical == [2, 3])
    }

    @Test("Distinct weights: one MST, and every edge in it is critical")
    func distinctWeights() {
        let edges = [[0, 1, 4], [0, 2, 2], [1, 2, 1], [1, 3, 5], [2, 4, 10], [3, 4, 2], [3, 5, 6], [4, 5, 3]]
        let roles = MSTEdgeRoles.classify(6, edges)
        #expect(roles.critical == [1, 2, 3, 5, 7])
        #expect(roles.pseudoCritical == [])
    }

    @Test("A cycle of equal weights: every edge is optional")
    func equalCycle() {
        let square = MSTEdgeRoles.classify(4, [[0, 1, 5], [1, 2, 5], [2, 3, 5], [3, 0, 5]])
        #expect(square.critical == [])
        #expect(square.pseudoCritical == [0, 1, 2, 3])
    }

    @Test("A bridge is critical however heavy it is")
    func bridge() {
        let edges = [[0, 1, 1], [1, 2, 1], [2, 0, 1], [2, 3, 100], [3, 4, 1], [4, 5, 1], [5, 3, 1]]
        let roles = MSTEdgeRoles.classify(6, edges)
        #expect(roles.critical == [3])
        #expect(roles.pseudoCritical == [0, 1, 2, 4, 5, 6])
    }

    @Test("Two nodes, parallel links")
    func parallel() {
        let tied = MSTEdgeRoles.classify(2, [[0, 1, 3], [1, 0, 3]])
        #expect(tied.critical == [])
        #expect(tied.pseudoCritical == [0, 1])
        let untied = MSTEdgeRoles.classify(2, [[0, 1, 3], [1, 0, 2]])
        #expect(untied.critical == [1])
        #expect(untied.pseudoCritical == [])
    }

    @Test("Random small graphs match listing every spanning tree", arguments: Array(1...15))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let n = 2 + steps.next(below: 5)
        // A random spanning tree first, so the graph is connected, then a few extra edges
        var edges = (1..<n).map { [$0, steps.next(below: $0), 1 + steps.next(below: 3)] }
        for _ in 0..<steps.next(below: 5) {
            let a = steps.next(below: n)
            var b = steps.next(below: n)
            if a == b { b = (a + 1) % n }
            edges.append([a, b, 1 + steps.next(below: 3)])
        }
        for index in stride(from: edges.count - 1, to: 0, by: -1) {
            edges.swapAt(index, steps.next(below: index + 1))
        }
        let roles = MSTEdgeRoles.classify(n, edges)
        let expected = model(n, edges)
        #expect(roles.critical == expected.critical)
        #expect(roles.pseudoCritical == expected.pseudoCritical)
    }

    @Test("150 nodes: a cheap chain plus 450 dearer links")
    func large() {
        // Every chain link is lighter than any other link around a cycle it's on, so all of them are
        // critical, and no other link is in any MST
        var steps = Steps(seed: 13)
        let n = 150
        var edges = (0..<(n - 1)).map { [$0, $0 + 1, 1] }
        for _ in 0..<450 {
            let a = steps.next(below: n)
            var b = steps.next(below: n)
            if a == b { b = (a + 1) % n }
            edges.append([a, b, 2 + steps.next(below: 50)])
        }
        let roles = MSTEdgeRoles.classify(n, edges)
        #expect(roles.critical == Array(0..<(n - 1)))
        #expect(roles.pseudoCritical == [])
    }
}
