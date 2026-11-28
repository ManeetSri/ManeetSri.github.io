import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CentreRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TreeNetworkCentresTests {
    private func adjacency(_ n: Int, _ cables: [[Int]]) -> [[Int]] {
        var neighbours = Array(repeating: [Int](), count: n)
        for cable in cables {
            neighbours[cable[0]].append(cable[1])
            neighbours[cable[1]].append(cable[0])
        }
        return neighbours
    }

    /// Hop counts from `start` to every building
    private func distances(from start: Int, _ neighbours: [[Int]]) -> [Int] {
        var distance = Array(repeating: -1, count: neighbours.count)
        distance[start] = 0
        var queue = [start]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            for next in neighbours[node] where distance[next] == -1 {
                distance[next] = distance[node] + 1
                queue.append(next)
            }
        }
        return distance
    }

    /// The buildings with the smallest eccentricity, by a BFS from every building
    private func brute(_ n: Int, _ cables: [[Int]]) -> [Int] {
        let neighbours = adjacency(n, cables)
        let eccentricity = (0..<n).map { distances(from: $0, neighbours).max()! }
        let best = eccentricity.min()!
        return (0..<n).filter { eccentricity[$0] == best }
    }

    /// A random tree: each building after the first joins an earlier one
    private func randomTree(_ n: Int, _ random: inout CentreRandom) -> [[Int]] {
        guard n > 1 else { return [] }
        return (1..<n).map { [$0, Int.random(in: 0..<$0, using: &random)] }
    }

    @Test("The examples", arguments: [
        (4, [[1, 0], [1, 2], [1, 3]], [1]),
        (6, [[3, 0], [3, 1], [3, 2], [3, 4], [5, 4]], [3, 4]),
        (5, [[0, 1], [1, 2], [2, 3], [3, 4]], [2]),
        (2, [[0, 1]], [0, 1]),
        (1, [], [0]),
    ])
    func examples(n: Int, cables: [[Int]], expected: [Int]) {
        #expect(TreeNetworkCentres.centres(buildings: n, cables: cables) == expected)
    }

    @Test("Random trees match a search from every building", arguments: [1, 2, 3])
    func matchesBrute(seed: UInt64) {
        var random = CentreRandom(seed: seed)
        for _ in 0..<200 {
            let n = Int.random(in: 1...30, using: &random)
            // Shuffle the labels, so the trees aren't always built in label order
            let labels = Array(0..<n).shuffled(using: &random)
            let cables = randomTree(n, &random).map { [labels[$0[0]], labels[$0[1]]] }
            let actual = TreeNetworkCentres.centres(buildings: n, cables: cables)
            #expect(actual == brute(n, cables), "n = \(n), cables \(cables)")
            if actual != brute(n, cables) { return }
        }
    }

    @Test("200,000 buildings: a long line, a star, and a random tree")
    func large() {
        let n = 200_000
        let line = (1..<n).map { [$0 - 1, $0] }
        #expect(TreeNetworkCentres.centres(buildings: n, cables: line) == [99_999, 100_000])
        let star = (1..<n).map { [0, $0] }
        #expect(TreeNetworkCentres.centres(buildings: n, cables: star) == [0])
        // A random tree, checked with two searches: the middle of a longest path
        var random = CentreRandom(seed: 59)
        let cables = randomTree(n, &random)
        let neighbours = adjacency(n, cables)
        let fromZero = distances(from: 0, neighbours)
        let a = fromZero.indices.max { fromZero[$0] < fromZero[$1] }!
        let fromA = distances(from: a, neighbours)
        let b = fromA.indices.max { fromA[$0] < fromA[$1] }!
        let fromB = distances(from: b, neighbours)
        let diameter = fromA[b]
        let middle = (0..<n).filter { fromA[$0] + fromB[$0] == diameter && abs(fromA[$0] - fromB[$0]) <= 1 }
        #expect(TreeNetworkCentres.centres(buildings: n, cables: cables) == middle.sorted())
    }
}
