import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CapitalProjectsTests {
    /// Tries every order of every set of contracts. Fine for six or so.
    private func exhaustive(_ capital: Int, _ k: Int, _ requirements: [Int], _ profits: [Int], used: Set<Int> = []) -> Int {
        guard k > 0 else { return capital }
        var best = capital
        for i in requirements.indices where !used.contains(i) && requirements[i] <= capital {
            best = max(best, exhaustive(capital + profits[i], k - 1, requirements, profits, used: used.union([i])))
        }
        return best
    }

    @Test("Small cases", arguments: [
        (0, 2, [0, 1, 1], [1, 2, 3], 4),
        (0, 3, [0, 1, 2], [1, 2, 3], 6),
        (5, 1, [10, 20], [100, 100], 5),
        (2, 2, [0, 0, 3], [1, 1, 50], 2 + 1 + 50),
        (1, 5, [1, 1], [4, 6], 11),
        (3, 0, [0], [9], 3),
        (0, 4, [Int](), [Int](), 0),
        (10, 2, [0, 5, 10, 12], [0, 0, 1, 7], 11),
    ])
    func small(start: Int, k: Int, requirements: [Int], profits: [Int], expected: Int) {
        #expect(CapitalProjects.bestFinalCapital(start: start, maxContracts: k, requirements: requirements, profits: profits) == expected)
    }

    @Test("Agrees with trying every order on hundreds of small inputs")
    func matchesExhaustive() {
        var mismatches = 0
        for seed in 1...200 {
            let n = 1 + seed % 6
            let requirements = (0..<n).map { ($0 * 7 + seed * 13) % 12 }
            let profits = (0..<n).map { ($0 * 5 + seed * 3) % 9 }
            let start = seed % 5
            let k = 1 + seed % 4
            let got = CapitalProjects.bestFinalCapital(start: start, maxContracts: k, requirements: requirements, profits: profits)
            if got != exhaustive(start, k, requirements, profits) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("100,000 contracts", arguments: [(10, 100_877), (1_000, 9_957_432), (50_000, 375_239_281), (100_000, 500_300_481)])
    func large(k: Int, expected: Int) {
        let requirements = (0..<100_000).map { ($0 * 7_919) % 1_000_003 }
        let profits = (0..<100_000).map { ($0 * 104_729) % 10_007 }
        #expect(CapitalProjects.bestFinalCapital(start: 1_000, maxContracts: k, requirements: requirements, profits: profits) == expected)
    }

    @Test("100,000 contracts that each unlock the next")
    func largeChain() {
        let requirements = Array((0..<100_000).reversed())       // listed hardest first
        let profits = Array(repeating: 1, count: 100_000)
        #expect(CapitalProjects.bestFinalCapital(start: 0, maxContracts: 100_000, requirements: requirements, profits: profits) == 100_000)
        #expect(CapitalProjects.bestFinalCapital(start: 0, maxContracts: 60_000, requirements: requirements, profits: profits) == 60_000)
    }
}
