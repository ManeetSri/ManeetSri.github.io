import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TransitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TransitReachabilityTests {
    /// A depth-first search for every query
    private func reference(_ n: Int, _ connections: [[Int]], _ queries: [[Int]]) -> [Bool] {
        var next: [[Int]] = Array(repeating: [], count: n)
        for connection in connections {
            next[connection[0]].append(connection[1])
        }
        return queries.map { query in
            var seen = Array(repeating: false, count: n)
            var stack = [query[0]]
            seen[query[0]] = true
            while let station = stack.popLast() {
                for other in next[station] where !seen[other] {
                    seen[other] = true
                    stack.append(other)
                }
            }
            return seen[query[1]]
        }
    }

    @Test("Example")
    func example() {
        let connections = [[0, 1], [1, 2], [3, 2], [2, 4]]
        let queries = [[0, 4], [4, 0], [3, 4], [0, 3], [2, 2], [1, 4]]
        #expect(TransitReachability.canReach(stationCount: 5, connections: connections, queries: queries)
            == [true, false, true, false, true, true])
    }

    @Test("Edge cases")
    func edgeCases() {
        // No connections: only yourself
        #expect(TransitReachability.canReach(stationCount: 3, connections: [], queries: [[0, 0], [0, 1], [2, 1]]) == [true, false, false])
        // No queries
        #expect(TransitReachability.canReach(stationCount: 2, connections: [[0, 1]], queries: []) == [])
        // A loop connects everything on it, both ways round
        let loop = [[0, 1], [1, 2], [2, 0]]
        #expect(TransitReachability.canReach(stationCount: 4, connections: loop, queries: [[2, 1], [1, 0], [0, 3], [3, 0]]) == [true, true, false, false])
        // A long one-way line
        let line = (0..<99).map { [$0, $0 + 1] }
        #expect(TransitReachability.canReach(stationCount: 100, connections: line, queries: [[0, 99], [99, 0], [50, 51], [51, 50]]) == [true, false, true, false])
    }

    @Test("Matches depth-first search on 300 small random networks")
    func randomSmall() {
        var random = TransitRandom(seed: 21)
        for _ in 0..<300 {
            let n = Int.random(in: 1...8, using: &random)
            let connections = (0..<Int.random(in: 0...12, using: &random)).map { _ in
                [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random)]
            }
            let queries = (0..<10).map { _ in [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random)] }
            #expect(TransitReachability.canReach(stationCount: n, connections: connections, queries: queries) == reference(n, connections, queries))
        }
    }

    @Test("300 stations, 600 connections and 10,000 queries")
    func large() {
        var random = TransitRandom(seed: 300)
        let n = 300
        let connections = (0..<600).map { _ in [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random)] }
        let queries = (0..<10_000).map { _ in [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random)] }
        let answers = TransitReachability.canReach(stationCount: n, connections: connections, queries: queries)
        // Checking 10,000 queries one by one is slow, so check a sample of them
        let sample = Array(stride(from: 0, to: 10_000, by: 25))
        #expect(answers.count == queries.count)
        if answers.count == queries.count {
            #expect(sample.map { answers[$0] } == reference(n, connections, sample.map { queries[$0] }))
        }
    }
}
