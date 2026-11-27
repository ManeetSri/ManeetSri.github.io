import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CharityRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CharityDrivePlansTests {
    private let mod = 1_000_000_007

    /// Brute force over every set of drives
    private func bruteForce(_ volunteers: Int, _ goal: Int, _ needs: [Int], _ raises: [Int]) -> Int {
        var count = 0
        for mask in 0..<(1 << needs.count) {
            var people = 0
            var money = 0
            for i in needs.indices where mask & (1 << i) != 0 {
                people += needs[i]
                money += raises[i]
            }
            if people <= volunteers && money >= goal { count += 1 }
        }
        return count
    }

    /// Pascal's triangle modulo 1,000,000,007
    private func pascal(_ size: Int) -> [[Int]] {
        var choose = Array(repeating: Array(repeating: 0, count: size + 1), count: size + 1)
        for n in 0...size {
            choose[n][0] = 1
            for k in stride(from: 1, through: n, by: 1) {
                choose[n][k] = (choose[n - 1][k - 1] + choose[n - 1][k]) % mod
            }
        }
        return choose
    }

    @Test("Examples and edge cases", arguments: [
        (4, 5, [2, 3, 1], [4, 5, 1], 3),
        (5, 3, [2, 2], [2, 3], 2),
        (3, 0, [2, 2], [0, 0], 3),
        (10, 50, [1, 1], [20, 20], 0),
        (1, 0, [2], [7], 1),
        (6, 4, [3, 3, 3], [2, 2, 2], 3),
    ] as [(Int, Int, [Int], [Int], Int)])
    func examples(volunteers: Int, goal: Int, needs: [Int], raises: [Int], expected: Int) {
        #expect(CharityDrivePlans.count(volunteers: volunteers, goal: goal, needs: needs, raises: raises) == expected)
    }

    @Test("Matches brute force on 300 small random cases")
    func randomSmall() {
        var random = CharityRandom(seed: 879)
        for _ in 0..<300 {
            let n = Int.random(in: 1...10, using: &random)
            let needs = (0..<n).map { _ in Int.random(in: 1...6, using: &random) }
            let raises = (0..<n).map { _ in Int.random(in: 0...8, using: &random) }
            let volunteers = Int.random(in: 1...20, using: &random)
            let goal = Int.random(in: 0...25, using: &random)
            #expect(CharityDrivePlans.count(volunteers: volunteers, goal: goal, needs: needs, raises: raises)
                    == bruteForce(volunteers, goal, needs, raises), "\(volunteers) \(goal) \(needs) \(raises)")
        }
    }

    @Test("100 identical drives: the count is a sum of binomial coefficients")
    func identical() {
        // Each drive needs 1 volunteer and raises 1, so a plan is any k drives with goal ≤ k ≤ volunteers
        let choose = pascal(100)
        let needs = Array(repeating: 1, count: 100)
        let raises = Array(repeating: 1, count: 100)
        for (volunteers, goal) in [(60, 40), (100, 0), (100, 100), (50, 51), (100, 1)] {
            var expected = 0
            if goal <= volunteers {
                for k in goal...volunteers {
                    expected = (expected + choose[100][k]) % mod
                }
            }
            #expect(CharityDrivePlans.count(volunteers: volunteers, goal: goal, needs: needs, raises: raises) == expected, "\(volunteers), \(goal)")
        }
    }

    @Test("Money beyond the goal still counts once")
    func clamping() {
        // Every drive raises far more than the goal, so any non-empty plan within the budget qualifies:
        // all 2^30 - 1 non-empty plans of single-volunteer drives, modulo the prime
        var allPlans = 1
        for _ in 0..<30 {
            allPlans = allPlans * 2 % mod
        }
        let count = CharityDrivePlans.count(volunteers: 100, goal: 1, needs: Array(repeating: 1, count: 30), raises: Array(repeating: 100, count: 30))
        #expect(count == (allPlans - 1 + mod) % mod)
    }
}
