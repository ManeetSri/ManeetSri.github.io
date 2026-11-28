import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StormRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StormRoadClosuresTests {
    /// After each closure, count the groups from scratch with a DFS over the roads still open
    private func reference(_ towns: Int, _ roads: [[Int]], _ closures: [Int]) -> [Int] {
        var open = Array(repeating: true, count: roads.count)
        var answer: [Int] = []
        for road in closures {
            open[road] = false
            var neighbours: [[Int]] = Array(repeating: [], count: towns)
            for (index, pair) in roads.enumerated() where open[index] {
                neighbours[pair[0]].append(pair[1])
                neighbours[pair[1]].append(pair[0])
            }
            var seen = Array(repeating: false, count: towns)
            var groups = 0
            for town in 0..<towns where !seen[town] {
                groups += 1
                seen[town] = true
                var stack = [town]
                while let here = stack.popLast() {
                    for next in neighbours[here] where !seen[next] {
                        seen[next] = true
                        stack.append(next)
                    }
                }
            }
            answer.append(groups)
        }
        return answer
    }

    @Test("Examples and small cases", arguments: [
        (4, [[0, 1], [1, 2], [2, 3], [3, 0]], [0, 2, 1], [1, 2, 3]),
        (3, [[0, 1], [0, 1], [1, 2]], [0, 2, 1], [1, 2, 3]),           // a spare road between 0 and 1
        (5, [[0, 1], [2, 3]], [], []),
        (3, [[0, 0], [1, 2]], [0], [2]),                                // closing a loop changes nothing
        (1, [], [], []),
        (4, [[0, 1], [1, 2], [2, 3]], [1], [2]),
        (4, [[0, 1], [1, 2], [2, 3]], [2, 1, 0], [2, 3, 4]),
        (2, [[0, 1], [1, 0]], [1, 0], [1, 2]),
        (6, [[0, 1], [1, 2], [3, 4], [4, 5], [2, 3]], [4, 0, 3], [2, 3, 4]),
    ] as [(Int, [[Int]], [Int], [Int])])
    func examples(towns: Int, roads: [[Int]], closures: [Int], expected: [Int]) {
        #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: roads, closures: closures) == expected)
    }

    @Test("Matches recounting after every closure on 400 random storms")
    func randomSmall() {
        var random = StormRandom(seed: 47)
        for _ in 0..<400 {
            let towns = Int.random(in: 1...8, using: &random)
            let roads = (0..<Int.random(in: 0...12, using: &random)).map { _ in
                [Int.random(in: 0..<towns, using: &random), Int.random(in: 0..<towns, using: &random)]
            }
            let closures = Array(Array(roads.indices).shuffled(using: &random).prefix(Int.random(in: 0...roads.count, using: &random)))
            #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: roads, closures: closures) == reference(towns, roads, closures))
        }
    }

    @Test("300 towns and 600 roads, every road closing")
    func mediumRandom() {
        var random = StormRandom(seed: 300)
        let towns = 300
        let roads = (0..<600).map { _ in [Int.random(in: 0..<towns, using: &random), Int.random(in: 0..<towns, using: &random)] }
        let closures = Array(roads.indices).shuffled(using: &random)
        #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: roads, closures: closures) == reference(towns, roads, closures))
    }

    @Test("100,000 towns in a line, a ring and a doubled line, every road closing")
    func large() {
        var random = StormRandom(seed: 100_000)
        let towns = 100_000

        // A line: every closure splits one group in two
        let line = (0..<(towns - 1)).map { [$0, $0 + 1] }
        let lineClosures = Array(line.indices).shuffled(using: &random)
        #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: line, closures: lineClosures) == Array(2...towns))

        // A ring: the first closure leaves a line, then each one splits a group
        let ring = (0..<towns).map { [$0, ($0 + 1) % towns] }
        let ringClosures = Array(ring.indices).shuffled(using: &random)
        #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: ring, closures: ringClosures) == Array(1...towns))

        // A line with every road doubled: a link breaks only when both of its copies have closed
        let doubled = line + line
        let doubledClosures = Array(doubled.indices).shuffled(using: &random)
        var closedCopies = Array(repeating: 0, count: towns - 1)
        var groups = 1
        var expected: [Int] = []
        for road in doubledClosures {
            let link = road % (towns - 1)
            closedCopies[link] += 1
            if closedCopies[link] == 2 { groups += 1 }
            expected.append(groups)
        }
        #expect(StormRoadClosures.groupsAfterEachClosure(towns: towns, roads: doubled, closures: doubledClosures) == expected)
    }
}
