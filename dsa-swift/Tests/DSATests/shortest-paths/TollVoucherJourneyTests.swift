import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct VoucherRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TollVoucherJourneyTests {
    /// Tries every set of at most `vouchers` roads to make free, with Bellman–Ford for each. Exponential.
    private func bruteForce(_ n: Int, _ roads: [[Int]], _ vouchers: Int) -> Int {
        var best = Int.max
        for mask in 0..<(1 << roads.count) where mask.nonzeroBitCount <= vouchers {
            var cost = Array(repeating: Int.max, count: n)
            cost[0] = 0
            for _ in 0..<n {
                for (index, road) in roads.enumerated() {
                    let toll = mask & (1 << index) != 0 ? 0 : road[2]
                    for (a, b) in [(road[0], road[1]), (road[1], road[0])] where cost[a] != Int.max {
                        cost[b] = min(cost[b], cost[a] + toll)
                    }
                }
            }
            best = min(best, cost[n - 1])
        }
        return best == Int.max ? -1 : best
    }

    private let example = [[0, 1, 10], [1, 3, 10], [0, 2, 1], [2, 3, 30]]

    @Test("Examples", arguments: [(0, 20), (1, 1), (2, 0), (5, 0)])
    func examples(vouchers: Int, expected: Int) {
        #expect(TollVoucherJourney.cheapestCost(cityCount: 4, roads: example, vouchers: vouchers) == expected)
    }

    @Test("Edge cases")
    func edgeCases() {
        // Already at the destination
        #expect(TollVoucherJourney.cheapestCost(cityCount: 1, roads: [], vouchers: 2) == 0)
        // No way through, vouchers or not
        #expect(TollVoucherJourney.cheapestCost(cityCount: 3, roads: [[0, 1, 4]], vouchers: 3) == -1)
        // Roads run both ways
        #expect(TollVoucherJourney.cheapestCost(cityCount: 2, roads: [[1, 0, 6]], vouchers: 0) == 6)
        // A voucher is best spent on the dearest road of the route, which needn't be the cheapest route
        #expect(TollVoucherJourney.cheapestCost(cityCount: 3, roads: [[0, 1, 50], [1, 2, 1], [0, 2, 40]], vouchers: 1) == 0)
        #expect(TollVoucherJourney.cheapestCost(cityCount: 4, roads: [[0, 1, 50], [1, 3, 2], [0, 2, 10], [2, 3, 10]], vouchers: 1) == 2)
    }

    @Test("Matches brute force on 300 small random maps")
    func randomSmall() {
        var random = VoucherRandom(seed: 11)
        for _ in 0..<300 {
            let n = Int.random(in: 1...6, using: &random)
            let roads = (0..<Int.random(in: 0...8, using: &random)).map { _ in
                [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random), Int.random(in: 0...25, using: &random)]
            }
            let vouchers = Int.random(in: 0...3, using: &random)
            #expect(TollVoucherJourney.cheapestCost(cityCount: n, roads: roads, vouchers: vouchers) == bruteForce(n, roads, vouchers))
        }
    }

    @Test("A 5,000-city motorway with a 5,000-city cul-de-sac network", arguments: [0, 1, 5, 10])
    func large(vouchers: Int) {
        // The motorway 0 – 1 – … – 4,999 is the only way to the end, with dearer parallel roads beside
        // it. The other 5,000 cities hang off city 0 in a tangle of 30,000 roads that leads nowhere, so
        // the answer is the motorway's total minus its `vouchers` dearest tolls.
        var random = VoucherRandom(seed: 5_000)
        let motorway = 5_000
        let tolls = (0..<(motorway - 1)).map { _ in Int.random(in: 1...10_000, using: &random) }
        var roads = tolls.enumerated().map { [$0.offset, $0.offset + 1, $0.element] }
        roads += tolls.enumerated().map { [$0.offset + 1, $0.offset, $0.element + 1] }
        roads.append([0, motorway, 1])
        for _ in 0..<30_000 {
            roads.append([Int.random(in: motorway..<(2 * motorway), using: &random), Int.random(in: motorway..<(2 * motorway), using: &random), Int.random(in: 0...100, using: &random)])
        }
        roads.shuffle(using: &random)
        let expected = tolls.reduce(0, +) - tolls.sorted(by: >).prefix(vouchers).reduce(0, +)
        // The destination is city 9,999, so swap it with the motorway's end
        let renamed = roads.map { road in road.enumerated().map { index, value in
            index == 2 ? value : (value == motorway - 1 ? 2 * motorway - 1 : (value == 2 * motorway - 1 ? motorway - 1 : value))
        } }
        #expect(TollVoucherJourney.cheapestCost(cityCount: 2 * motorway, roads: renamed, vouchers: vouchers) == expected)
    }
}
