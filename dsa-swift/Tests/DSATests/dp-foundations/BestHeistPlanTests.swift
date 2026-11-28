import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HeistPlanRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BestHeistPlanTests {
    /// The best total, with two states per house: robbed or not
    private func bestTotal(_ houses: [Int]) -> Int {
        var (robbed, notRobbed) = (0, 0)
        for cash in houses {
            (robbed, notRobbed) = (notRobbed + cash, max(robbed, notRobbed))
        }
        return max(robbed, notRobbed)
    }

    /// A plan is right if its houses are real, in increasing order, never neighbours, and add up to the best
    private func isBestPlan(_ plan: [Int], for houses: [Int]) -> Bool {
        var previous = -2
        var total = 0
        for index in plan {
            guard index >= 0, index < houses.count, index >= previous + 2 else {
                return false
            }
            total += houses[index]
            previous = index
        }
        return total == bestTotal(houses)
    }

    @Test("Streets with exactly one best plan", arguments: [
        ([5, 8, 6, 1, 2, 9], [0, 2, 5]),
        ([3, 10, 3, 1, 2], [1, 4]),
        ([2, 9, 4, 3, 8], [1, 4]),
        ([5, 1, 1, 5], [0, 3]),
        ([4], [0]),
        ([], []),
        ([1, 3, 1, 3, 100], [1, 4]),
    ] as [([Int], [Int])])
    func uniquePlans(houses: [Int], expected: [Int]) {
        #expect(BestHeistPlan.bestPlan(houses: houses) == expected)
    }

    @Test("Streets with several best plans: any of them is accepted", arguments: [
        [2, 3, 1],
        [2, 2, 2, 2],
        [1, 1, 1, 2, 1],
        [0, 0, 0],
        [6, 0, 6, 6, 0, 6],
    ])
    func tiedPlans(houses: [Int]) {
        let plan = BestHeistPlan.bestPlan(houses: houses)
        #expect(isBestPlan(plan, for: houses), "plan \(plan) for \(houses)")
    }

    @Test("Valid best plans on 400 small random streets")
    func randomSmall() {
        var random = HeistPlanRandom(seed: 3_141)
        for _ in 0..<400 {
            let houses = (0..<Int.random(in: 0...15, using: &random)).map { _ in Int.random(in: 0...6, using: &random) }
            let plan = BestHeistPlan.bestPlan(houses: houses)
            #expect(isBestPlan(plan, for: houses), "plan \(plan) for \(houses)")
        }
    }

    @Test("Streets of 100,000 houses")
    func large() {
        let alternating = (0..<100_000).map { $0 % 2 == 0 ? 10_000 : 1 }
        #expect(BestHeistPlan.bestPlan(houses: alternating) == Array(stride(from: 0, to: 100_000, by: 2)))

        var random = HeistPlanRandom(seed: 100_000)
        for _ in 0..<3 {
            let houses = (0..<100_000).map { _ in Int.random(in: 0...10_000, using: &random) }
            let plan = BestHeistPlan.bestPlan(houses: houses)
            #expect(isBestPlan(plan, for: houses))
        }
    }
}
