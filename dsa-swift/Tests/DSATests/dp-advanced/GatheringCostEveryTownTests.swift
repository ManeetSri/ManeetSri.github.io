import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct GatheringRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct GatheringCostEveryTownTests {
    /// The total distance from every town to `source`, by walking the whole tree from it (with a stack)
    private func totalFrom(_ source: Int, _ n: Int, _ roads: [[Int]]) -> Int {
        var neighbours = [[(Int, Int)]](repeating: [], count: n)
        for road in roads {
            neighbours[road[0]].append((road[1], road[2]))
            neighbours[road[1]].append((road[0], road[2]))
        }
        var distance = [Int](repeating: -1, count: n)
        distance[source] = 0
        var stack = [source]
        var total = 0
        while let v = stack.popLast() {
            total += distance[v]
            for (w, length) in neighbours[v] where distance[w] == -1 {
                distance[w] = distance[v] + length
                stack.append(w)
            }
        }
        return total
    }

    /// A random tree: town i joins a random earlier town, then the labels are shuffled
    private func randomTree(_ n: Int, maxLength: Int, using random: inout GatheringRandom) -> [[Int]] {
        let label = (0..<n).shuffled(using: &random)
        var roads: [[Int]] = []
        for town in 1..<max(n, 1) {
            let earlier = Int.random(in: 0..<town, using: &random)
            roads.append([label[town], label[earlier], Int.random(in: 1...maxLength, using: &random)])
        }
        return roads.shuffled(using: &random)
    }

    @Test("Examples and small cases", arguments: [
        (1, [], [0]),
        (2, [[0, 1, 5]], [5, 5]),
        (4, [[0, 1, 2], [1, 2, 3], [1, 3, 1]], [10, 6, 12, 8]),
        (5, [[0, 1, 1], [0, 2, 1], [0, 3, 1], [0, 4, 1]], [4, 7, 7, 7, 7]),
        (4, [[3, 2, 1], [2, 1, 1], [1, 0, 1]], [6, 4, 4, 6]),
    ] as [(Int, [[Int]], [Int])])
    func examples(n: Int, roads: [[Int]], expected: [Int]) {
        #expect(GatheringCostEveryTown.totalTravel(n: n, roads: roads) == expected)
    }

    @Test("Matches a walk from every town on 300 small random trees")
    func randomSmall() {
        var random = GatheringRandom(seed: 58)
        for _ in 0..<300 {
            let n = Int.random(in: 1...30, using: &random)
            let roads = randomTree(n, maxLength: 20, using: &random)
            let expected = (0..<n).map { totalFrom($0, n, roads) }
            #expect(GatheringCostEveryTown.totalTravel(n: n, roads: roads) == expected)
        }
    }

    @Test("A chain of 100,000 towns, too deep for recursion in a test")
    func chain() {
        // Town i sits at position[i] along a line, so the answer for i is the sum of |position[i] - position[j]|
        var random = GatheringRandom(seed: 100)
        let n = 100_000
        var position = [0]
        var roads: [[Int]] = []
        for town in 1..<n {
            let length = Int.random(in: 1...10_000, using: &random)
            position.append(position[town - 1] + length)
            roads.append([town - 1, town, length])
        }
        var expected = [Int](repeating: 0, count: n)
        var before = 0                                        // sum of positions to the left
        let all = position.reduce(0, +)
        for town in 0..<n {
            let after = all - before - position[town]
            expected[town] = town * position[town] - before + after - (n - 1 - town) * position[town]
            before += position[town]
        }
        #expect(GatheringCostEveryTown.totalTravel(n: n, roads: roads.reversed()) == expected)
    }

    @Test("A random tree and a star of 100,000 towns, spot-checked")
    func large() {
        var random = GatheringRandom(seed: 2_058)
        let n = 100_000
        let roads = randomTree(n, maxLength: 10_000, using: &random)
        let answer = GatheringCostEveryTown.totalTravel(n: n, roads: roads)
        #expect(answer.count == n)
        if answer.count == n {
            for town in [0, 1, 777, 54_321, n - 1] {
                #expect(answer[town] == totalFrom(town, n, roads))
            }
        }

        let star = (1..<n).map { [0, $0, 3] }
        let starAnswer = GatheringCostEveryTown.totalTravel(n: n, roads: star)
        #expect(starAnswer.first == 3 * (n - 1))
        #expect(starAnswer.last == 3 + 6 * (n - 2))
    }
}
