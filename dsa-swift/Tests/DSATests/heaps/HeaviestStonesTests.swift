import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HeaviestStonesTests {
    /// The rules followed literally: sort, smash the last two, repeat. Fine for small piles.
    private func simulate(_ weights: [Int]) -> Int {
        var pile = weights
        while pile.count > 1 {
            pile.sort()
            let heaviest = pile.removeLast()
            let next = pile.removeLast()
            if heaviest > next { pile.append(heaviest - next) }
        }
        return pile.first ?? 0
    }

    @Test("Small piles", arguments: [
        ([3, 9, 4, 2, 6], 0),
        ([10, 4, 3], 3),
        ([7], 7),
        ([5, 5], 0),
        ([8, 1], 7),
        ([1, 1, 1], 1),
        ([2, 7, 4, 1, 8, 1], 1),
        ([20, 3, 3, 3], 11),
        ([Int](), 0),
    ])
    func small(weights: [Int], expected: Int) {
        #expect(HeaviestStones.lastStone(weights) == expected)
    }

    @Test("Agrees with a step-by-step simulation on hundreds of piles")
    func matchesSimulation() {
        var mismatches = 0
        for seed in 1...300 {
            let count = 1 + seed % 25
            let weights = (0..<count).map { ($0 * 7_919 + seed * 104_729) % (3 + seed % 60) + 1 }
            if HeaviestStones.lastStone(weights) != simulate(weights) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("100,000 stones")
    func large() {
        let mixed = (0..<100_000).map { ($0 * 7_919 + 17) % 100_003 + 1 }
        #expect(HeaviestStones.lastStone(mixed) == 1)
        #expect(HeaviestStones.lastStone(Array(1...100_000)) == 0)
        #expect(HeaviestStones.lastStone(Array(repeating: 5, count: 100_000)) == 0)
        #expect(HeaviestStones.lastStone(Array(repeating: 5, count: 99_999)) == 5)
        #expect(HeaviestStones.lastStone([1_000_000] + Array(repeating: 1, count: 99_999)) == 900_001)
    }
}
