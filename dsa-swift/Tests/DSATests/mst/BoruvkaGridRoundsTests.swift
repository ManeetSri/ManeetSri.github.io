import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BoruvkaRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BoruvkaGridRoundsTests {
    /// Borůvka without union-find: before each round, label every town's grid with a BFS over the lines
    /// built so far, then scan every line for each grid's cheapest way out
    private func reference(_ towns: Int, _ lines: [[Int]]) -> (cost: Int, gridsAfterRound: [Int]) {
        var builtNeighbours: [[Int]] = Array(repeating: [], count: towns)
        var cost = 0
        var history: [Int] = []
        while true {
            var label = Array(repeating: -1, count: towns)
            var grids = 0
            for town in 0..<towns where label[town] == -1 {
                label[town] = grids
                var queue = [town]
                var head = 0
                while head < queue.count {
                    let here = queue[head]
                    head += 1
                    for next in builtNeighbours[here] where label[next] == -1 {
                        label[next] = grids
                        queue.append(next)
                    }
                }
                grids += 1
            }
            var cheapest = Array(repeating: -1, count: grids)
            for (index, line) in lines.enumerated() {
                let a = label[line[0]], b = label[line[1]]
                if a == b { continue }
                for grid in [a, b] {
                    let current = cheapest[grid]
                    if current == -1 || (line[2], index) < (lines[current][2], current) { cheapest[grid] = index }
                }
            }
            let picked = Set(cheapest.filter { $0 != -1 })
            if picked.isEmpty { return (cost, history) }
            for index in picked {                       // each joins two different grids, so it's new
                cost += lines[index][2]
                builtNeighbours[lines[index][0]].append(lines[index][1])
                builtNeighbours[lines[index][1]].append(lines[index][0])
            }
            // Count the grids after this round
            var seen = Array(repeating: false, count: towns)
            var after = 0
            for town in 0..<towns where !seen[town] {
                after += 1
                seen[town] = true
                var stack = [town]
                while let here = stack.popLast() {
                    for next in builtNeighbours[here] where !seen[next] {
                        seen[next] = true
                        stack.append(next)
                    }
                }
            }
            history.append(after)
        }
    }

    /// Kruskal: the minimum spanning forest's total, by a different method
    private func kruskal(_ towns: Int, _ lines: [[Int]]) -> (cost: Int, grids: Int) {
        var parent = Array(0..<towns)
        func find(_ x: Int) -> Int {
            var root = x
            while parent[root] != root { root = parent[root] }
            var node = x
            while node != root { (node, parent[node]) = (parent[node], root) }
            return root
        }
        var cost = 0
        var grids = towns
        for line in lines.sorted(by: { $0[2] < $1[2] }) {
            let a = find(line[0]), b = find(line[1])
            if a != b {
                parent[a] = b
                cost += line[2]
                grids -= 1
            }
        }
        return (cost, grids)
    }

    private static let lessonLines = [[0, 1, 4], [0, 2, 2], [1, 2, 1], [1, 3, 5], [2, 4, 10], [3, 4, 2], [3, 5, 6], [4, 5, 3]]
    private static let ringLines = (0..<16).map { [$0, ($0 + 1) % 16, ($0 * 7) % 16 + 1] }

    @Test("Examples and small cases", arguments: [
        (6, lessonLines, 13, [2, 1]),
        (16, ringLines, 120, [7, 2, 1]),
        (3, [[0, 1, 1], [1, 2, 1], [2, 0, 1]], 2, [1]),                     // ties broken by position
        (4, [[0, 1, 1], [1, 2, 1], [2, 3, 1], [3, 0, 1]], 3, [1]),
        (5, [[0, 1, 3], [2, 3, 1]], 4, [3]),                                 // town 4 is never connected
        (1, [], 0, []),
        (3, [[1, 1, 5]], 0, []),                                             // a line from a town to itself
        (2, [[0, 1, 5], [0, 1, 2]], 2, [1]),
        (4, [[0, 1, 1], [1, 2, 2], [2, 3, 3]], 6, [1]),
        (4, [[0, 1, 1], [2, 3, 1], [1, 2, 9], [0, 3, 8]], 10, [2, 1]),
        (3, [[0, 1, 0], [1, 2, 0]], 0, [1]),
    ] as [(Int, [[Int]], Int, [Int])])
    func examples(towns: Int, lines: [[Int]], cost: Int, rounds: [Int]) {
        let plan = BoruvkaGridRounds.plan(towns: towns, lines: lines)
        #expect(plan.cost == cost)
        #expect(plan.gridsAfterRound == rounds)
    }

    @Test("Matches a union-find-free Borůvka and Kruskal on 500 random networks with many ties")
    func randomSmall() {
        var random = BoruvkaRandom(seed: 46)
        for _ in 0..<500 {
            let towns = Int.random(in: 1...9, using: &random)
            let lines = (0..<Int.random(in: 0...15, using: &random)).map { _ in
                [Int.random(in: 0..<towns, using: &random), Int.random(in: 0..<towns, using: &random), Int.random(in: 0...6, using: &random)]
            }
            let plan = BoruvkaGridRounds.plan(towns: towns, lines: lines)
            let expected = reference(towns, lines)
            #expect(plan.cost == expected.cost)
            #expect(plan.gridsAfterRound == expected.gridsAfterRound)
            #expect(plan.cost == kruskal(towns, lines).cost)
        }
    }

    @Test("50,000 connected towns and 150,000 lines: grids at least halve every round")
    func largeConnected() {
        var random = BoruvkaRandom(seed: 100_000)
        let towns = 50_000
        var lines = (1..<towns).map { [$0, Int.random(in: 0..<$0, using: &random), Int.random(in: 0...1_000_000, using: &random)] }
        while lines.count < 150_000 {
            lines.append([Int.random(in: 0..<towns, using: &random), Int.random(in: 0..<towns, using: &random), Int.random(in: 0...1_000_000, using: &random)])
        }
        lines.shuffle(using: &random)
        let plan = BoruvkaGridRounds.plan(towns: towns, lines: lines)
        #expect(plan.cost == kruskal(towns, lines).cost)
        #expect(plan.gridsAfterRound.last == 1)
        #expect(plan.gridsAfterRound.count <= 16)                            // log₂ 50,000 ≈ 15.6
        var previous = towns
        for grids in plan.gridsAfterRound {
            #expect(grids * 2 <= previous)
            previous = grids
        }
        let expected = reference(towns, lines)
        #expect(plan.gridsAfterRound == expected.gridsAfterRound)
    }

    @Test("60,000 towns in many separate regions, with equal costs everywhere")
    func largeSeparate() {
        // Towns only connect within their own block of 30, and every line costs 1, so ties are broken
        // by position alone. Each block ends as its own grid.
        var random = BoruvkaRandom(seed: 60_000)
        let towns = 60_000
        var lines: [[Int]] = []
        for block in stride(from: 0, to: towns, by: 30) {
            for _ in 0..<60 {
                lines.append([block + Int.random(in: 0..<30, using: &random), block + Int.random(in: 0..<30, using: &random), 1])
            }
        }
        lines.shuffle(using: &random)
        let plan = BoruvkaGridRounds.plan(towns: towns, lines: lines)
        let forest = kruskal(towns, lines)
        #expect(plan.cost == forest.cost)
        #expect(plan.gridsAfterRound.last == forest.grids)
        #expect(plan.gridsAfterRound == reference(towns, lines).gridsAfterRound)
    }
}
