import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TrailRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TrailRouteCountTests {
    private let mod = 1_000_000_007

    /// Brute force: walk every route from start, one trail at a time, and count arrivals at finish
    private func bruteForce(_ n: Int, _ trails: [[Int]], _ start: Int, _ finish: Int) -> Int {
        var outgoing = [[Int]](repeating: [], count: n)
        for trail in trails { outgoing[trail[0]].append(trail[1]) }
        var routes = 0
        var stack = [start]
        while let v = stack.popLast() {
            if v == finish { routes += 1 }
            stack.append(contentsOf: outgoing[v])
        }
        return routes
    }

    /// A random DAG: trails only go from a lower rank to a higher one, then junctions are relabelled
    private func randomDAG(_ n: Int, trails count: Int, using random: inout TrailRandom) -> [[Int]] {
        let label = (0..<n).shuffled(using: &random)
        var trails: [[Int]] = []
        for _ in 0..<count {
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            if a != b { trails.append([label[min(a, b)], label[max(a, b)]]) }
        }
        return trails
    }

    @Test("Examples and small cases", arguments: [
        (5, [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4], [1, 4]], 0, 4, 3),
        (3, [[0, 1], [0, 1], [1, 2]], 0, 2, 2),
        (3, [[1, 0], [2, 1]], 0, 2, 0),
        (4, [[0, 1], [2, 3]], 2, 2, 1),
        (1, [], 0, 0, 1),
        (4, [[3, 1], [3, 2], [1, 0], [2, 0], [3, 0]], 3, 0, 3),
    ] as [(Int, [[Int]], Int, Int, Int)])
    func examples(n: Int, trails: [[Int]], start: Int, finish: Int, expected: Int) {
        #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: start, finish: finish) == expected)
    }

    @Test("Matches walking every route on 400 small random maps")
    func randomSmall() {
        var random = TrailRandom(seed: 58)
        for _ in 0..<400 {
            let n = Int.random(in: 1...9, using: &random)
            let trails = randomDAG(n, trails: Int.random(in: 0...16, using: &random), using: &random)
            let start = Int.random(in: 0..<n, using: &random), finish = Int.random(in: 0..<n, using: &random)
            #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: start, finish: finish) == bruteForce(n, trails, start, finish))
        }
    }

    @Test("A scrambled ladder of 100,000 junctions: Fibonacci numbers modulo p")
    func ladder() {
        // Rung i leads to rungs i + 1 and i + 2, so the routes from rung 0 to rung k follow Fibonacci
        var random = TrailRandom(seed: 100)
        let n = 100_000
        let label = (0..<n).shuffled(using: &random)
        var trails: [[Int]] = []
        for rung in 0..<(n - 1) {
            trails.append([label[rung], label[rung + 1]])
            if rung + 2 < n { trails.append([label[rung], label[rung + 2]]) }
        }
        trails.shuffle(using: &random)
        var fibonacci = [1, 1]
        while fibonacci.count < n {
            fibonacci.append((fibonacci[fibonacci.count - 1] + fibonacci[fibonacci.count - 2]) % mod)
        }
        #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: label[0], finish: label[n - 1]) == fibonacci[n - 1])
        #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: label[500], finish: label[600]) == fibonacci[100])
        #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: label[600], finish: label[500]) == 0)
    }

    @Test("A chain of 100,000 junctions with doubled trails: 2^99,999 modulo p")
    func doubledChain() {
        let n = 100_000
        var trails: [[Int]] = []
        for v in stride(from: n - 1, to: 0, by: -1) {
            trails.append([v, v - 1])
            trails.append([v, v - 1])
        }
        var power = 1
        for _ in 0..<(n - 1) { power = power * 2 % mod }
        #expect(TrailRouteCount.countRoutes(n: n, trails: trails, start: n - 1, finish: 0) == power)
    }
}
