import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BiscuitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BiscuitsForChildrenTests {
    /// Tries every way to hand out the biscuits: each child in turn goes without, or takes any unused
    /// biscuit that satisfies them. Exponential, so only for a few children.
    private func exhaustive(_ greed: [Int], _ biscuits: [Int]) -> Int {
        var used = Array(repeating: false, count: biscuits.count)
        func best(from child: Int) -> Int {
            if child == greed.count { return 0 }
            var result = best(from: child + 1)                  // this child goes without
            for b in biscuits.indices where !used[b] && biscuits[b] >= greed[child] {
                used[b] = true
                result = max(result, 1 + best(from: child + 1))
                used[b] = false
            }
            return result
        }
        return best(from: 0)
    }

    @Test("Examples and small cases", arguments: [
        ([5, 2, 8, 3], [4, 1, 3, 9, 2], 3),
        ([1, 4, 2], [3, 1, 1], 2),
        ([3, 3], [2, 2, 2], 0),
        ([1, 1, 1], [5], 1),
        ([2], [1, 2, 3], 1),
        ([], [1, 2], 0),
        ([4, 5], [], 0),
        ([10, 9, 8, 7], [7, 8, 9, 10], 4),
        ([6, 1, 6], [6, 6, 1], 3),
    ] as [([Int], [Int], Int)])
    func examples(greed: [Int], biscuits: [Int], expected: Int) {
        #expect(BiscuitsForChildren.happyChildren(greed: greed, biscuits: biscuits) == expected)
    }

    @Test("Matches trying every handout on 500 small random cases")
    func randomSmall() {
        var random = BiscuitRandom(seed: 50)
        for _ in 0..<500 {
            let greed = (0..<Int.random(in: 0...6, using: &random)).map { _ in Int.random(in: 1...8, using: &random) }
            let biscuits = (0..<Int.random(in: 0...6, using: &random)).map { _ in Int.random(in: 1...8, using: &random) }
            #expect(BiscuitsForChildren.happyChildren(greed: greed, biscuits: biscuits) == exhaustive(greed, biscuits),
                    "greed \(greed), biscuits \(biscuits)")
        }
    }

    @Test("100,000 children and 100,000 biscuits")
    func large() {
        var random = BiscuitRandom(seed: 2_026)
        let n = 100_000
        // Greed 2...n+1 against sizes 1...n, both shuffled: every child but the greediest is happy
        let greed = Array(2...(n + 1)).shuffled(using: &random)
        let biscuits = Array(1...n).shuffled(using: &random)
        #expect(BiscuitsForChildren.happyChildren(greed: greed, biscuits: biscuits) == n - 1)

        // Every biscuit is one size too small for its matching child, except the very biggest
        let huge = Array(repeating: 1_000_000_000, count: n)
        #expect(BiscuitsForChildren.happyChildren(greed: huge, biscuits: Array(repeating: 999_999_999, count: n)) == 0)
        #expect(BiscuitsForChildren.happyChildren(greed: huge, biscuits: huge) == n)

        // Random sizes: the biggest-first greedy from the lesson must agree
        let someGreed = (0..<n).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        let someBiscuits = (0..<(n / 2)).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        let children = someGreed.sorted(by: >), sizes = someBiscuits.sorted(by: >)
        var biggestFirst = 0
        for need in children where biggestFirst < sizes.count && sizes[biggestFirst] >= need {
            biggestFirst += 1
        }
        #expect(BiscuitsForChildren.happyChildren(greed: someGreed, biscuits: someBiscuits) == biggestFirst)
    }
}
