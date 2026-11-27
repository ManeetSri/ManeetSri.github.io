import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct OdometerPotentialTests {
    // A plain odometer simulation: the actual cost of each increment, and the final digits
    static func actualCosts(increments n: Int, base b: Int) -> (costs: [Int], digits: [Int]) {
        var digits = [0]
        var costs: [Int] = []
        for _ in 0..<n {
            var position = 0
            while position < digits.count && digits[position] == b - 1 {
                digits[position] = 0
                position += 1
            }
            if position == digits.count {
                digits.append(1)
            } else {
                digits[position] += 1
            }
            costs.append(position + 1)
        }
        return (costs, digits)
    }

    @Test("Total examples", arguments: [(10, 10, 11), (100, 10, 111), (1_000, 10, 1_111), (7, 2, 11), (5, 3, 6), (1_000, 16, 1_065), (0, 10, 0), (1, 2, 1)])
    func totalExamples(n: Int, base: Int, expected: Int) {
        #expect(OdometerPotential.totalChanges(increments: n, base: base) == expected)
    }

    @Test("Totals match a simulation", arguments: [2, 3, 7, 10, 16, 36])
    func totalMatchesSimulation(base: Int) {
        let costs = Self.actualCosts(increments: 3_000, base: base).costs
        var running = 0
        var wrong: [Int] = []
        for n in 1...3_000 {
            running += costs[n - 1]
            if OdometerPotential.totalChanges(increments: n, base: base) != running {
                wrong.append(n)
            }
        }
        #expect(wrong.isEmpty, "base \(base): wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Totals for n = 10¹⁸, without simulating")
    func totalHuge() {
        #expect(OdometerPotential.totalChanges(increments: 1_000_000_000_000_000_000, base: 10) == 1_111_111_111_111_111_111)
        #expect(OdometerPotential.totalChanges(increments: 1_000_000_000_000_000_000, base: 2) == 1_999_999_999_999_999_976)
        #expect(OdometerPotential.totalChanges(increments: 1_000_000_000_000_000_000, base: 36) == 1_028_571_428_571_428_564)
    }

    @Test("Amortised examples")
    func amortisedExamples() {
        #expect(OdometerPotential.amortisedCosts(increments: 12, base: 10) == [1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1])
        #expect(OdometerPotential.amortisedCosts(increments: 4, base: 2) == [2, 2, 2, 2])
        #expect(OdometerPotential.amortisedCosts(increments: 0, base: 10) == [])
        // base 3: 0 → 1 → 2 → 10 → 11 → 12 → 20 → 21 → 22 → 100
        #expect(OdometerPotential.amortisedCosts(increments: 9, base: 3) == [1, 2, 1, 1, 2, 2, 1, 2, 1])
    }

    @Test("Base 2 always costs exactly 2")
    func binaryIsTwo() {
        #expect(OdometerPotential.amortisedCosts(increments: 5_000, base: 2) == Array(repeating: 2, count: 5_000))
    }

    @Test("Amortised costs are 1 or 2, and add up to actual + final Φ", arguments: [3, 7, 10, 36])
    func potentialAccounting(base: Int) {
        let n = 100_000
        let amortised = OdometerPotential.amortisedCosts(increments: n, base: base)
        let (costs, digits) = Self.actualCosts(increments: n, base: base)
        #expect(amortised.count == n)
        #expect(amortised.allSatisfy { $0 == 1 || $0 == 2 })
        let finalPotential = digits.filter { $0 == base - 1 }.count
        #expect(amortised.reduce(0, +) == costs.reduce(0, +) + finalPotential)
    }
}
