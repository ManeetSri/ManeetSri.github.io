import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CityRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct QuietestCityWithinReachTests {
    /// A different method: the O(n²) array version of Dijkstra from every city
    private func reference(_ n: Int, _ roads: [[Int]], _ maxDistance: Int) -> Int {
        var length = Array(repeating: Array(repeating: Int.max, count: n), count: n)
        for road in roads {
            length[road[0]][road[1]] = min(length[road[0]][road[1]], road[2])
            length[road[1]][road[0]] = min(length[road[1]][road[0]], road[2])
        }
        var best = 0
        var fewest = Int.max
        for city in 0..<n {
            var distance = Array(repeating: Int.max, count: n)
            var done = Array(repeating: false, count: n)
            distance[city] = 0
            for _ in 0..<n {
                var closest = -1
                for v in 0..<n where !done[v] && distance[v] != Int.max && (closest == -1 || distance[v] < distance[closest]) {
                    closest = v
                }
                if closest == -1 { break }
                done[closest] = true
                for v in 0..<n where length[closest][v] != Int.max {
                    distance[v] = min(distance[v], distance[closest] + length[closest][v])
                }
            }
            let count = (0..<n).filter { $0 != city && distance[$0] <= maxDistance }.count
            if count < fewest {
                fewest = count
                best = city
            }
        }
        return best
    }

    @Test("Examples and small maps", arguments: [
        (4, [[0, 1, 3], [1, 2, 1], [2, 3, 4], [0, 3, 9]], 4, 3),
        (4, [[0, 1, 3], [1, 2, 1], [2, 3, 4], [0, 3, 9]], 5, 0),
        (5, [[0, 1, 2], [1, 2, 2], [2, 3, 2], [3, 4, 2]], 3, 0),
        (3, [[0, 1, 5], [1, 2, 5]], 4, 0),
        (3, [[0, 1, 1], [1, 2, 1]], 1, 0),
        (4, [[1, 2, 1]], 10, 0),
        (4, [[0, 1, 1], [0, 2, 1], [0, 3, 1]], 1, 1),
        (2, [[0, 1, 4], [0, 1, 2]], 3, 0),
    ] as [(Int, [[Int]], Int, Int)])
    func examples(n: Int, roads: [[Int]], maxDistance: Int, expected: Int) {
        #expect(QuietestCityWithinReach.city(cityCount: n, roads: roads, maxDistance: maxDistance) == expected)
    }

    @Test("Routes through other cities count")
    func indirectRoutes() {
        // 0 – 1 – 2 – 3 in a line of 2s: city 3 reaches 2 and 1 within 4; city 0 reaches 1 and 2 as well,
        // but the long direct road 0 – 3 of 5 doesn't bring 3 within 4 of 0.
        let roads = [[0, 1, 2], [1, 2, 2], [2, 3, 2], [0, 3, 5]]
        #expect(QuietestCityWithinReach.city(cityCount: 4, roads: roads, maxDistance: 4) == 0)
        // A limit of 5 lets 0 reach 3 directly, so 0 now reaches three cities. Everyone does.
        #expect(QuietestCityWithinReach.city(cityCount: 4, roads: roads, maxDistance: 5) == 0)
    }

    @Test("Matches repeated Dijkstra on 300 small random maps")
    func randomSmall() {
        var random = CityRandom(seed: 15)
        for _ in 0..<300 {
            let n = Int.random(in: 1...8, using: &random)
            let roads = (0..<Int.random(in: 0...14, using: &random)).compactMap { _ -> [Int]? in
                let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
                return a == b ? nil : [a, b, Int.random(in: 1...10, using: &random)]
            }
            let limit = Int.random(in: 0...20, using: &random)
            #expect(QuietestCityWithinReach.city(cityCount: n, roads: roads, maxDistance: limit) == reference(n, roads, limit))
        }
    }

    @Test("150 cities with every pair joined", arguments: [50, 400, 2_000])
    func large(maxDistance: Int) {
        var random = CityRandom(seed: UInt64(maxDistance))
        var roads: [[Int]] = []
        for a in 0..<150 {
            for b in (a + 1)..<150 {
                roads.append([a, b, Int.random(in: 1...10_000, using: &random)])
            }
        }
        #expect(QuietestCityWithinReach.city(cityCount: 150, roads: roads, maxDistance: maxDistance) == reference(150, roads, maxDistance))
    }
}
