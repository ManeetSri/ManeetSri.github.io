import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PaintRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HousePaintingCostTests {
    /// Try every colouring with no two neighbours alike
    private func everyColouring(_ costs: [[Int]]) -> Int {
        if costs.isEmpty { return 0 }
        let k = costs[0].count
        func paint(_ house: Int, after previous: Int) -> Int {
            if house == costs.count { return 0 }
            var best = Int.max
            for colour in 0..<k where colour != previous {
                let rest = paint(house + 1, after: colour)
                if rest != Int.max { best = min(best, costs[house][colour] + rest) }
            }
            return best
        }
        let best = paint(0, after: -1)
        return best == Int.max ? -1 : best
    }

    /// The O(n · k²) method: every colour checks every other colour of the previous house
    private func quadratic(_ costs: [[Int]]) -> Int {
        var previous = costs[0]
        for house in costs.dropFirst() {
            previous = house.indices.map { colour in
                house[colour] + previous.indices.filter { $0 != colour }.map { previous[$0] }.min()!
            }
        }
        return previous.min()!
    }

    private func randomCosts(houses: Int, colours: Int, values: ClosedRange<Int>, using random: inout PaintRandom) -> [[Int]] {
        (0..<houses).map { _ in (0..<colours).map { _ in Int.random(in: values, using: &random) } }
    }

    @Test("Examples and small streets", arguments: [
        ([[7, 3, 8, 6], [5, 6, 2, 9], [4, 9, 6, 5], [8, 1, 7, 3]], 10),
        ([[1, 2], [1, 10]], 3),
        ([], 0),
        ([[4, 2, 7]], 2),
        ([[5], [3]], -1),
        ([[6]], 6),
        ([[1, 1], [1, 1], [1, 1]], 3),
        ([[2, 2, 9], [2, 9, 9]], 4),
        ([[0, 0, 0], [0, 0, 0]], 0),
    ] as [([[Int]], Int)])
    func examples(costs: [[Int]], expected: Int) {
        #expect(HousePaintingCost.minimumCost(costs) == expected)
    }

    @Test("Matches trying every colouring on 300 small random streets")
    func randomSmall() {
        var random = PaintRandom(seed: 256)
        for _ in 0..<300 {
            let costs = randomCosts(houses: Int.random(in: 0...6, using: &random),
                                    colours: Int.random(in: 1...4, using: &random), values: 0...20, using: &random)
            #expect(HousePaintingCost.minimumCost(costs) == everyColouring(costs))
        }
    }

    @Test("Ties for the cheapest colour")
    func ties() {
        // Colours 0 and 2 tie for the cheapest first house, so colour 0 on the second house can still
        // follow colour 2 at the same price
        #expect(HousePaintingCost.minimumCost([[1, 5, 1], [1, 9, 9]]) == 2)
        #expect(HousePaintingCost.minimumCost([[3, 3], [3, 3], [3, 3], [3, 3]]) == 12)
    }

    @Test("Medium streets match the O(n · k²) method")
    func medium() {
        var random = PaintRandom(seed: 400)
        for (houses, colours) in [(400, 100), (1_000, 2), (50, 3)] {
            let costs = randomCosts(houses: houses, colours: colours, values: 0...10_000, using: &random)
            #expect(HousePaintingCost.minimumCost(costs) == quadratic(costs))
        }
    }

    @Test("2,000 houses and 500 colours: a planted free colouring, and equal prices")
    func large() {
        // O(n · k²) would be 500 million steps here
        var random = PaintRandom(seed: 2_000)
        var costs = randomCosts(houses: 2_000, colours: 500, values: 1...10_000, using: &random)
        var colour = Int.random(in: 0..<500, using: &random)
        for house in 0..<2_000 {
            costs[house][colour] = 0
            colour = (colour + Int.random(in: 1..<500, using: &random)) % 500   // always a different colour
        }
        #expect(HousePaintingCost.minimumCost(costs) == 0)

        let equal = Array(repeating: Array(repeating: 3, count: 500), count: 2_000)
        #expect(HousePaintingCost.minimumCost(equal) == 6_000)
    }
}
