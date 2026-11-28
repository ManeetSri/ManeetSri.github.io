import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64) that also counts how many random numbers were drawn
private struct DepotRandom: RandomNumberGenerator {
    private var state: UInt64
    private(set) var draws = 0

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        draws += 1
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct WeightedMedianDepotTests {
    /// Sort, then walk until half the weight is reached
    private func reference(_ positions: [Int], _ weights: [Int]) -> (Int, Int) {
        let shops = zip(positions, weights).sorted { $0.0 < $1.0 }
        let total = weights.reduce(0, +)
        var running = 0
        var spot = shops[0].0
        for shop in shops {
            running += shop.1
            if 2 * running >= total {
                spot = shop.0
                break
            }
        }
        return (spot, zip(positions, weights).reduce(0) { $0 + $1.1 * abs($1.0 - spot) })
    }

    @Test("The examples", arguments: [
        ([1, 3, 7, 10], [1, 1, 1, 1], 3, 13),
        ([1, 3, 7, 10], [1, 1, 1, 5], 10, 19),
        ([4, 4, 2, 9], [1, 2, 3, 1], 4, 11),
        ([-5, 0, 5], [2, 1, 2], 0, 20),
        ([8], [3], 8, 0),
    ])
    func examples(positions: [Int], weights: [Int], spot: Int, cost: Int) {
        var random = DepotRandom(seed: 1)
        let result = WeightedMedianDepot.bestSpot(positions: positions, weights: weights, using: &random)
        #expect(result.spot == spot)
        #expect(result.cost == cost)
    }

    @Test("Ties go to the smallest cheapest spot")
    func ties() {
        var random = DepotRandom(seed: 2)
        let pair = WeightedMedianDepot.bestSpot(positions: [10, 20], weights: [4, 4], using: &random)
        #expect(pair.spot == 10 && pair.cost == 40)
        let reversed = WeightedMedianDepot.bestSpot(positions: [20, 10], weights: [4, 4], using: &random)
        #expect(reversed.spot == 10 && reversed.cost == 40)
        let flat = WeightedMedianDepot.bestSpot(positions: [9, 1, 5, 3], weights: [2, 1, 1, 2], using: &random)
        #expect(flat.spot == 3 && flat.cost == 16)
    }

    @Test("Random roads match sorting, with every seed giving the same answer", arguments: [1, 2, 3, 4])
    func matchesReference(seed: UInt64) {
        var random = DepotRandom(seed: seed)
        var data = DepotRandom(seed: seed + 100)
        for trial in 0..<300 {
            let n = Int.random(in: 1...25, using: &data)
            let spread = trial.isMultiple(of: 2) ? 5 : 1_000_000_000
            let positions = (0..<n).map { _ in Int.random(in: -spread...spread, using: &data) }
            let weights = (0..<n).map { _ in Int.random(in: 1...(trial.isMultiple(of: 3) ? 1 : 1_000), using: &data) }
            let result = WeightedMedianDepot.bestSpot(positions: positions, weights: weights, using: &random)
            let expected = reference(positions, weights)
            #expect(result.spot == expected.0 && result.cost == expected.1, "positions \(positions), weights \(weights)")
            if result.spot != expected.0 || result.cost != expected.1 { return }
        }
    }

    @Test("200,000 shops: few random draws, and correct")
    func large() {
        var data = DepotRandom(seed: 67)
        let n = 200_000
        let positions = (0..<n).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &data) }
        let weights = (0..<n).map { _ in Int.random(in: 1...1_000, using: &data) }
        var random = DepotRandom(seed: 5)
        let result = WeightedMedianDepot.bestSpot(positions: positions, weights: weights, using: &random)
        let expected = reference(positions, weights)
        #expect(result.spot == expected.0 && result.cost == expected.1)
        #expect(random.draws >= 1, "draw the pivots from the generator; a sort draws nothing")
        #expect(random.draws <= 300, "expected O(log n) rounds, but \(random.draws) random numbers were drawn")
    }

    @Test("200,000 shops at one position, and 200,000 shops already in order")
    func adversarial() {
        let n = 200_000
        var random = DepotRandom(seed: 6)
        let same = WeightedMedianDepot.bestSpot(positions: Array(repeating: 42, count: n), weights: Array(repeating: 7, count: n), using: &random)
        #expect(same.spot == 42 && same.cost == 0)
        #expect(random.draws <= 300)

        var ordered = DepotRandom(seed: 7)
        let positions = Array(0..<n)
        let weights = (0..<n).map { $0 % 10 + 1 }
        let result = WeightedMedianDepot.bestSpot(positions: positions, weights: weights, using: &ordered)
        let expected = reference(positions, weights)
        #expect(result.spot == expected.0 && result.cost == expected.1)
        #expect(ordered.draws >= 1 && ordered.draws <= 300)
    }
}
