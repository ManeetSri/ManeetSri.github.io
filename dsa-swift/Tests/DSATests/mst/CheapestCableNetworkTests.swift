import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CheapestCableNetworkTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The answer by a different method: Prim's algorithm on a cost matrix, O(n²).
    private func modelCost(_ n: Int, _ options: [[Int]]) -> Int {
        var cost = Array(repeating: Array(repeating: Int.max, count: n), count: n)
        for option in options {
            cost[option[0]][option[1]] = min(cost[option[0]][option[1]], option[2])
            cost[option[1]][option[0]] = cost[option[0]][option[1]]
        }
        var inTree = Array(repeating: false, count: n)
        var cheapest = Array(repeating: Int.max, count: n)
        cheapest[0] = 0
        var total = 0
        for _ in 0..<n {
            guard let next = (0..<n).filter({ !inTree[$0] }).min(by: { cheapest[$0] < cheapest[$1] }),
                  cheapest[next] != Int.max else { return -1 }
            inTree[next] = true
            total += cheapest[next]
            for v in 0..<n where !inTree[v] && cost[next][v] < cheapest[v] {
                cheapest[v] = cost[next][v]
            }
        }
        return total
    }

    @Test("Small networks", arguments: [
        (4, [[0, 1, 3], [1, 2, 1], [2, 3, 4], [0, 3, 2], [0, 2, 5]], 6),
        (3, [[0, 1, 4], [1, 2, 4], [0, 2, 4]], 8),
        (5, [[0, 1, 1], [1, 2, 2], [2, 3, 3], [3, 4, 4], [0, 4, 1], [1, 3, 1]], 5),
        (2, [[0, 1, 7], [1, 0, 3]], 3),
        (3, [[0, 1, 0], [1, 2, 0]], 0),
    ])
    func examples(n: Int, options: [[Int]], expected: Int) {
        #expect(CheapestCableNetwork.minimumCost(n, options) == expected)
    }

    @Test("Impossible networks return -1")
    func impossible() {
        #expect(CheapestCableNetwork.minimumCost(3, [[0, 1, 5]]) == -1)
        #expect(CheapestCableNetwork.minimumCost(4, [[0, 1, 1], [2, 3, 1]]) == -1)
        #expect(CheapestCableNetwork.minimumCost(2, []) == -1)
    }

    @Test("One city needs no cables")
    func single() {
        #expect(CheapestCableNetwork.minimumCost(1, []) == 0)
    }

    @Test("Random networks match Prim's algorithm", arguments: Array(1...12))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let n = 2 + steps.next(below: 30)
        let options = (0..<steps.next(below: 3 * n)).map { _ -> [Int] in
            let a = steps.next(below: n)
            var b = steps.next(below: n)
            if a == b { b = (a + 1) % n }
            return [a, b, steps.next(below: 20)]
        }
        #expect(CheapestCableNetwork.minimumCost(n, options) == modelCost(n, options))
    }

    @Test("300 cities and 20,000 options match Prim's algorithm")
    func medium() {
        var steps = Steps(seed: 5)
        let n = 300
        let options = (0..<20_000).map { _ -> [Int] in
            let a = steps.next(below: n)
            var b = steps.next(below: n)
            if a == b { b = (a + 1) % n }
            return [a, b, 1 + steps.next(below: 1_000)]
        }
        #expect(CheapestCableNetwork.minimumCost(n, options) == modelCost(n, options))
    }

    @Test("20,000 cities: a cheap chain hidden among 80,000 dearer options")
    func large() {
        var steps = Steps(seed: 8)
        let n = 20_000
        var options = (0..<(n - 1)).map { [$0, $0 + 1, 1] }
        for _ in 0..<80_000 {
            options.append([steps.next(below: n), steps.next(below: n), 2 + steps.next(below: 1_000)])
        }
        for index in stride(from: options.count - 1, to: 0, by: -1) {
            options.swapAt(index, steps.next(below: index + 1))
        }
        #expect(CheapestCableNetwork.minimumCost(n, options) == n - 1)
    }
}
