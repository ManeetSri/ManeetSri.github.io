import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BudgetInputSizeTests {
    typealias Growth = BudgetInputSize.Growth

    // Step counts straight from the table, for small n only
    static func steps(_ growth: Growth, _ n: Int) -> Int {
        switch growth {
        case .linear: return n
        case .linearithmic:
            var log = 0
            var size = n
            while size > 1 {
                size /= 2
                log += 1
            }
            return n * log
        case .quadratic: return n * n
        case .cubic: return n * n * n
        case .exponential: return 1 << n
        case .factorial: return n <= 1 ? 1 : (2...n).reduce(1, *)
        }
    }

    @Test("A budget of 10⁸, about one second", arguments: [
        (Growth.linear, 100_000_000), (.linearithmic, 4_545_454), (.quadratic, 10_000),
        (.cubic, 464), (.exponential, 26), (.factorial, 11),
    ])
    func oneSecond(growth: Growth, expected: Int) {
        #expect(BudgetInputSize.largestInput(for: growth, budget: 100_000_000) == expected)
    }

    @Test("A budget of 10¹¹: a computer 1,000 times faster", arguments: [
        (Growth.linear, 100_000_000_000), (.linearithmic, 3_225_806_451), (.quadratic, 316_227),
        (.cubic, 4_641), (.exponential, 36), (.factorial, 14),
    ])
    func thousandTimesFaster(growth: Growth, expected: Int) {
        #expect(BudgetInputSize.largestInput(for: growth, budget: 100_000_000_000) == expected)
    }

    @Test("The largest budget, 10¹²", arguments: [
        (Growth.linear, 1_000_000_000_000), (.linearithmic, 29_411_764_705), (.quadratic, 1_000_000),
        (.cubic, 10_000), (.exponential, 39), (.factorial, 14),
    ])
    func largestBudget(growth: Growth, expected: Int) {
        #expect(BudgetInputSize.largestInput(for: growth, budget: 1_000_000_000_000) == expected)
    }

    @Test("Tiny budgets", arguments: [
        (Growth.linear, 1, 1), (.linearithmic, 1, 1), (.quadratic, 1, 1), (.cubic, 1, 1), (.exponential, 1, 0), (.factorial, 1, 1),
        (.linearithmic, 2, 2), (.linearithmic, 7, 3), (.linearithmic, 8, 4), (.exponential, 2, 1), (.factorial, 2, 2),
        (.quadratic, 3, 1), (.quadratic, 4, 2), (.cubic, 26, 2), (.cubic, 27, 3), (.factorial, 5, 2), (.factorial, 6, 3),
    ])
    func tinyBudgets(growth: Growth, budget: Int, expected: Int) {
        #expect(BudgetInputSize.largestInput(for: growth, budget: budget) == expected)
    }

    @Test("Matches the table for every budget up to 3,000", arguments: Growth.allCases)
    func matchesTable(growth: Growth) {
        var wrong: [Int] = []
        var n = 0
        for budget in 1...3_000 {
            while Self.steps(growth, n + 1) <= budget {
                n += 1
            }
            if BudgetInputSize.largestInput(for: growth, budget: budget) != n {
                wrong.append(budget)
            }
        }
        #expect(wrong.isEmpty, "wrong for budgets \(Array(wrong.prefix(5)))")
    }

    @Test("n log n lands exactly on band edges")
    func linearithmicBandEdges() {
        // 2²⁰ = 1,048,576 costs 1,048,576 × 20; one less costs (2²⁰ − 1) × 19
        #expect(BudgetInputSize.largestInput(for: .linearithmic, budget: 1_048_576 * 20) == 1_048_576)
        #expect(BudgetInputSize.largestInput(for: .linearithmic, budget: 1_048_576 * 20 - 1) == 1_048_575)
        #expect(BudgetInputSize.largestInput(for: .linearithmic, budget: 1_048_575 * 19) == 1_048_575)
        #expect(BudgetInputSize.largestInput(for: .linearithmic, budget: 1_048_575 * 19 - 1) == 1_048_574)
    }
}
