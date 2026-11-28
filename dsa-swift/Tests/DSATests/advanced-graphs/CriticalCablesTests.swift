import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct CableRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct CriticalCablesTests {
    private func groups(_ n: Int, _ cables: [[Int]], skipping skipped: Int) -> Int {
        var parent = Array(0..<n)
        func root(_ x: Int) -> Int {
            var x = x
            while parent[x] != x { x = parent[x] }
            return x
        }
        var count = n
        for (index, cable) in cables.enumerated() where index != skipped {
            let a = root(cable[0]), b = root(cable[1])
            if a != b {
                parent[a] = b
                count -= 1
            }
        }
        return count
    }

    /// Brute force: remove each cable in turn and count the groups.
    private func bruteForce(_ n: Int, _ cables: [[Int]]) -> [[Int]] {
        let before = groups(n, cables, skipping: -1)
        return cables.indices
            .filter { groups(n, cables, skipping: $0) > before }
            .map { [min(cables[$0][0], cables[$0][1]), max(cables[$0][0], cables[$0][1])] }
            .sorted { $0.lexicographicallyPrecedes($1) }
    }

    @Test("Small networks", arguments: [
        // The lesson's network: a triangle, a bridge, another triangle and a two-cable tail
        (8, [[0, 1], [0, 2], [1, 2], [1, 3], [3, 4], [3, 5], [4, 5], [5, 6], [6, 7]], [[1, 3], [5, 6], [6, 7]]),
        (4, [[0, 1], [1, 2], [2, 3], [3, 0]], []),
        (4, [[0, 1], [1, 2], [1, 3]], [[0, 1], [1, 2], [1, 3]]),
        (2, [[1, 0]], [[0, 1]]),
        (1, [], []),
        (5, [[4, 3], [2, 4], [3, 2], [0, 1]], [[0, 1]]),
        (6, [[0, 1], [1, 2], [2, 0], [3, 4]], [[3, 4]]),
    ] as [(Int, [[Int]], [[Int]])])
    func smallNetworks(n: Int, cables: [[Int]], expected: [[Int]]) {
        #expect(CriticalCables.find(n, cables) == expected)
    }

    @Test("Parallel cables back each other up")
    func parallelCables() {
        #expect(CriticalCables.find(3, [[0, 1], [0, 1], [1, 2]]) == [[1, 2]])
        #expect(CriticalCables.find(2, [[0, 1], [1, 0]]) == [])
        #expect(CriticalCables.find(4, [[0, 1], [1, 2], [2, 1], [2, 3], [3, 2], [3, 2]]) == [[0, 1]])
    }

    @Test("Matches brute force on 300 random small networks")
    func randomSmall() {
        var random = CableRandom(state: 2_026)
        for _ in 0..<300 {
            let n = 2 + random.next(9)
            var cables: [[Int]] = []
            for _ in 0..<random.next(15) {
                let a = random.next(n), b = random.next(n)
                if a != b { cables.append([a, b]) }
            }
            #expect(CriticalCables.find(n, cables) == bruteForce(n, cables))
        }
    }

    @Test("30,000 triangles around a hub, each with a dangling server")
    func flower() {
        // Hub 0; triangle i is 0, a, b; server c hangs off a. Only the a–c cables are critical.
        var cables: [[Int]] = []
        var expected: [[Int]] = []
        for i in 0..<30_000 {
            let a = 3 * i + 1, b = 3 * i + 2, c = 3 * i + 3
            cables += [[0, a], [a, b], [b, 0], [c, a]]
            expected.append([a, c])
        }
        #expect(CriticalCables.find(90_001, cables) == expected)
    }

    @Test("A line and a ring with a tail, 100,000 servers each (needs an iterative DFS)")
    func deepLineAndRing() {
        let line = (0..<99_999).map { [$0, $0 + 1] }
        #expect(CriticalCables.find(100_000, line) == line)

        // Servers 0..<50,000 form a ring; 50,000..<100,000 form a tail hanging off server 0
        let ring = (0..<50_000).map { [$0, ($0 + 1) % 50_000] }
        let tail = [[0, 50_000]] + (50_000..<99_999).map { [$0, $0 + 1] }
        #expect(CriticalCables.find(100_000, ring + tail) == tail)
    }
}
