// Reference solution: The biggest input for a budget. Short loops for the fast-growing classes, which
// check the next size before moving to it. For n log n, ⌊log₂ n⌋ is k across the band 2ᵏ to 2ᵏ⁺¹ − 1,
// so each band is settled in one step: about 40 bands for any budget.

public enum BudgetInputSize {
    public enum Growth: CaseIterable {
        case linear, linearithmic, quadratic, cubic, exponential, factorial
    }

    public static func largestInput(for growth: Growth, budget: Int) -> Int {
        switch growth {
        case .linear:
            return budget
        case .linearithmic:
            var best = 1                                  // n = 1 costs 0 steps
            var k = 1
            while budget / k >= 1 << k {                  // the band starting at 2ᵏ has room
                best = min(budget / k, (1 << (k + 1)) - 1)
                k += 1
            }
            return best
        case .quadratic:
            var n = 0
            while (n + 1) * (n + 1) <= budget {           // at most 10⁶ passes
                n += 1
            }
            return n
        case .cubic:
            var n = 0
            while (n + 1) * (n + 1) * (n + 1) <= budget {
                n += 1
            }
            return n
        case .exponential:
            var n = 0
            var power = 1                                 // 2ⁿ
            while power * 2 <= budget {
                power *= 2
                n += 1
            }
            return n
        case .factorial:
            var n = 1
            var product = 1                               // n!
            while product * (n + 1) <= budget {
                product *= n + 1
                n += 1
            }
            return n
        }
    }
}
