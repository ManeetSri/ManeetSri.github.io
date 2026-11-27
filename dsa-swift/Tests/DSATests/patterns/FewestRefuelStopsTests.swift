import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RefuelRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FewestRefuelStopsTests {
    /// Try every set of stations to stop at: clearly right, for up to about 12 stations
    private func byEverySet(_ target: Int, _ startFuel: Int, _ stations: [[Int]]) -> Int {
        var best = -1
        for mask in 0..<(1 << stations.count) {
            var fuel = startFuel
            var position = 0
            var made = true
            for (i, station) in stations.enumerated() {
                fuel -= station[0] - position
                position = station[0]
                if fuel < 0 {
                    made = false
                    break
                }
                if mask & (1 << i) != 0 { fuel += station[1] }
            }
            if made, fuel >= target - position {
                let stops = mask.nonzeroBitCount
                if best == -1 || stops < best { best = stops }
            }
        }
        return best
    }

    /// farthest[k] is the farthest position reachable with exactly k stops among the stations seen so far.
    /// O(n²), a different and well-known correct method.
    private func byFarthestReach(_ target: Int, _ startFuel: Int, _ stations: [[Int]]) -> Int {
        var farthest = Array(repeating: 0, count: stations.count + 1)
        farthest[0] = startFuel
        for (i, station) in stations.enumerated() {
            for k in stride(from: i, through: 0, by: -1) where farthest[k] >= station[0] {
                farthest[k + 1] = max(farthest[k + 1], farthest[k] + station[1])
            }
        }
        return farthest.firstIndex { $0 >= target } ?? -1
    }

    private func randomTrip(stations count: Int, using random: inout RefuelRandom) -> (Int, Int, [[Int]]) {
        let target = Int.random(in: (count + 1)...(count * 20 + 20), using: &random)
        var positions = Set<Int>()
        while positions.count < min(count, target - 1) {
            positions.insert(Int.random(in: 1..<target, using: &random))
        }
        let stations = positions.sorted().map { [$0, Int.random(in: 1...30, using: &random)] }
        return (target, Int.random(in: 1...30, using: &random), stations)
    }

    @Test("Examples and small cases", arguments: [
        (50, 15, [[10, 10], [15, 20], [30, 5], [40, 25]], 3),
        (60, 20, [[5, 30], [10, 10], [20, 15], [45, 5]], 2),
        (10, 10, [], 0),
        (30, 5, [[10, 100]], -1),
        (100, 25, [[20, 15], [25, 40], [50, 10], [60, 30], [75, 20]], 3),
        (40, 10, [[10, 5], [12, 4], [14, 30]], 2),
        (10, 3, [[3, 7]], 1),
        (1, 1, [], 0),
        (5, 100, [[1, 1], [2, 1]], 0),
    ] as [(Int, Int, [[Int]], Int)])
    func examples(target: Int, startFuel: Int, stations: [[Int]], expected: Int) {
        #expect(FewestRefuelStops.fewestStops(target: target, startFuel: startFuel, stations: stations) == expected)
    }

    @Test("Matches trying every set of stops, on 400 small trips")
    func randomSmall() {
        var random = RefuelRandom(seed: 459)
        for _ in 0..<400 {
            let (target, fuel, stations) = randomTrip(stations: Int.random(in: 0...10, using: &random), using: &random)
            #expect(FewestRefuelStops.fewestStops(target: target, startFuel: fuel, stations: stations) == byEverySet(target, fuel, stations))
        }
    }

    @Test("Matches the farthest-reach DP on 10 trips with 2,000 stations")
    func randomMedium() {
        var random = RefuelRandom(seed: 2_459)
        for _ in 0..<10 {
            let (target, fuel, stations) = randomTrip(stations: 2_000, using: &random)
            #expect(FewestRefuelStops.fewestStops(target: target, startFuel: fuel, stations: stations) == byFarthestReach(target, fuel, stations))
        }
    }

    @Test("100,000 stations")
    func large() {
        // A station every 10 km with 10 litres each, starting with 10: every station is needed
        let n = 100_000
        let chain = (1...n).map { [$0 * 10, 10] }
        #expect(FewestRefuelStops.fewestStops(target: 10 * (n + 1), startFuel: 10, stations: chain) == n)
        #expect(FewestRefuelStops.fewestStops(target: 10 * (n + 1) + 1, startFuel: 10, stations: chain) == -1)

        // Huge distances: one big station at the very end of the first tank does it in one stop
        let far = (1..<n).map { [$0 * 10_000, $0 == 100 ? 1_000_000_000 : 1] }
        #expect(FewestRefuelStops.fewestStops(target: 1_000_000_000, startFuel: 1_000_000, stations: far) == 1)
    }
}
