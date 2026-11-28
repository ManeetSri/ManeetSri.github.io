import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct DistrictRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct OneWayDistrictsTests {
    /// Brute force for small cities: junctions a and b share a district when each reaches the other.
    private func bruteForce(_ n: Int, _ roads: [[Int]]) -> Int {
        var reaches = [[Bool]](repeating: [Bool](repeating: false, count: n), count: n)
        for v in 0..<n { reaches[v][v] = true }
        for road in roads { reaches[road[0]][road[1]] = true }
        for k in 0..<n {
            for i in 0..<n where reaches[i][k] {
                for j in 0..<n where reaches[k][j] { reaches[i][j] = true }
            }
        }
        var claimed = [Bool](repeating: false, count: n)
        var districts = 0
        for v in 0..<n where !claimed[v] {
            districts += 1
            for w in 0..<n where reaches[v][w] && reaches[w][v] { claimed[w] = true }
        }
        return districts
    }

    @Test("The lesson's city: three districts")
    func lessonCity() {
        let roads = [[0, 1], [1, 2], [2, 0], [1, 3], [2, 4], [3, 4], [4, 5], [5, 3], [5, 6], [6, 7], [7, 6], [0, 7]]
        #expect(OneWayDistricts.count(8, roads) == 3)
    }

    @Test("Small cities", arguments: [
        (5, [[0, 1], [1, 2], [2, 3], [3, 4]], 5),
        (5, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]], 1),
        (4, [], 4),
        (1, [], 1),
        (2, [[0, 1], [1, 0]], 1),
        (3, [[0, 0], [1, 1], [0, 1], [0, 1], [1, 2]], 3),
        (6, [[0, 1], [1, 0], [2, 3], [3, 2], [4, 5], [5, 4], [1, 2], [3, 4]], 3),
        (7, [[0, 1], [1, 2], [2, 0], [3, 4], [4, 5], [5, 3], [6, 6]], 3),
        (6, [[5, 4], [4, 3], [3, 5], [2, 1], [1, 0], [0, 2], [3, 0]], 2),
    ] as [(Int, [[Int]], Int)])
    func smallCities(n: Int, roads: [[Int]], expected: Int) {
        #expect(OneWayDistricts.count(n, roads) == expected)
    }

    @Test("Matches brute force on 300 random small cities")
    func randomSmall() {
        var random = DistrictRandom(state: 41)
        for _ in 0..<300 {
            let n = 1 + random.next(9)
            let roads = (0..<random.next(18)).map { _ in [random.next(n), random.next(n)] }
            #expect(OneWayDistricts.count(n, roads) == bruteForce(n, roads))
        }
    }

    @Test("1,000 districts in 100,000 junctions, linked in ten layers")
    func manyDistricts() {
        // Each district is a hub with 99 spokes, driven both ways. Hubs in layer L have roads to hubs
        // in layer L + 1 only, so no road leads back and every district stays separate.
        var roads: [[Int]] = []
        for district in 0..<1_000 {
            let hub = district * 100
            for spoke in 1..<100 {
                roads.append([hub, hub + spoke])
                roads.append([hub + spoke, hub])
            }
        }
        for district in 0..<900 {
            let layer = district / 100
            for step in [7, 31, 64] {
                let target = (layer + 1) * 100 + (district + step) % 100
                roads.append([district * 100 + step, target * 100])
            }
        }
        #expect(OneWayDistricts.count(100_000, roads) == 1_000)
    }

    @Test("One district: a hub with 99,999 two-way spokes")
    func oneBigDistrict() {
        let roads = (1..<100_000).flatMap { [[0, $0], [$0, 0]] }
        #expect(OneWayDistricts.count(100_000, roads) == 1)
    }

    @Test("A chain and a ring of 100,000 junctions (needs an iterative DFS)")
    func deepChainAndRing() {
        let chain = (0..<99_999).map { [$0, $0 + 1] }
        #expect(OneWayDistricts.count(100_000, chain) == 100_000)
        #expect(OneWayDistricts.count(100_000, chain + [[99_999, 0]]) == 1)
    }
}
