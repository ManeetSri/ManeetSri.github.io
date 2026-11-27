import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BudgetRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ZeroOneStringBudgetTests {
    /// Brute force: the biggest subset of strings that fits both budgets
    private func bruteForce(_ strings: [String], _ zeros: Int, _ ones: Int) -> Int {
        let costs = strings.map { string in (string.filter { $0 == "0" }.count, string.filter { $0 == "1" }.count) }
        var best = 0
        for mask in 0..<(1 << strings.count) {
            var z = 0
            var o = 0
            var chosen = 0
            for i in strings.indices where mask & (1 << i) != 0 {
                z += costs[i].0
                o += costs[i].1
                chosen += 1
            }
            if z <= zeros && o <= ones { best = max(best, chosen) }
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        (["01", "1100", "0", "111", "00"], 3, 3, 3),
        (["01", "1100", "0", "111", "00"], 1, 1, 1),
        (["01", "1100", "0", "111", "00"], 4, 2, 3),
        (["11", "11", "0"], 0, 3, 1),
        (["1", "1", "1"], 0, 2, 2),
        (["000"], 2, 5, 0),
        (["10", "01", "1", "0"], 0, 0, 0),
        (["0", "0", "1", "1"], 100, 100, 4),
    ] as [([String], Int, Int, Int)])
    func examples(strings: [String], zeros: Int, ones: Int, expected: Int) {
        #expect(ZeroOneStringBudget.mostStrings(strings, zeros: zeros, ones: ones) == expected)
    }

    @Test("Strings of a single digit can't be chosen twice")
    func singleDigit() {
        #expect(ZeroOneStringBudget.mostStrings(["11", "11", "11"], zeros: 5, ones: 4) == 2)
        #expect(ZeroOneStringBudget.mostStrings(["11"], zeros: 3, ones: 100) == 1)
        #expect(ZeroOneStringBudget.mostStrings(["00"], zeros: 100, ones: 3) == 1)
        #expect(ZeroOneStringBudget.mostStrings(["00", "00", "11"], zeros: 4, ones: 2) == 3)
    }

    @Test("Matches brute force on 300 small random cases")
    func randomSmall() {
        var random = BudgetRandom(seed: 474)
        for _ in 0..<300 {
            let strings = (0..<Int.random(in: 1...10, using: &random)).map { _ in
                String((0..<Int.random(in: 1...5, using: &random)).map { _ in Bool.random(using: &random) ? Character("1") : Character("0") })
            }
            let zeros = Int.random(in: 0...8, using: &random)
            let ones = Int.random(in: 0...8, using: &random)
            #expect(ZeroOneStringBudget.mostStrings(strings, zeros: zeros, ones: ones) == bruteForce(strings, zeros, ones), "\(strings) \(zeros) \(ones)")
        }
    }

    @Test("600 strings and budgets up to 100")
    func large() {
        var random = BudgetRandom(seed: 600)
        // 250 single 0s and 250 single 1s, plus 100 long strings that fit but are never worth it, shuffled
        var mixed = Array(repeating: "0", count: 250) + Array(repeating: "1", count: 250)
        mixed += (0..<100).map { _ in String(repeating: "0", count: 60) + String(repeating: "1", count: 40) }
        mixed.shuffle(using: &random)
        #expect(ZeroOneStringBudget.mostStrings(mixed, zeros: 100, ones: 100) == 200)
        #expect(ZeroOneStringBudget.mostStrings(mixed, zeros: 37, ones: 60) == 97)

        // 600 copies of "01": each uses one of each
        #expect(ZeroOneStringBudget.mostStrings(Array(repeating: "01", count: 600), zeros: 30, ones: 64) == 30)

        // Long strings: 50 zeros and 50 ones each, so at most two fit in budgets of 100
        let long = String(repeating: "01", count: 50)
        #expect(ZeroOneStringBudget.mostStrings(Array(repeating: long, count: 600), zeros: 100, ones: 100) == 2)
    }
}
