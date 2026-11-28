import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StonesRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StoneSmashLeftoverTests {
    /// Plays the game itself: tries every pair at every turn and returns the lightest ending
    private func playEveryWay(_ stones: [Int]) -> Int {
        if stones.count <= 1 { return stones.first ?? 0 }
        var best = Int.max
        for i in stones.indices {
            for j in stones.indices where j > i {
                var rest = stones
                rest.remove(at: j)
                rest.remove(at: i)
                let leftover = abs(stones[i] - stones[j])
                if leftover > 0 { rest.append(leftover) }
                best = min(best, playEveryWay(rest.sorted()))
            }
        }
        return best
    }

    /// Brute force over every split into two piles
    private func bestSplit(_ stones: [Int]) -> Int {
        let total = stones.reduce(0, +)
        var best = total
        for mask in 0..<(1 << stones.count) {
            var pile = 0
            for i in stones.indices where mask & (1 << i) != 0 {
                pile += stones[i]
            }
            best = min(best, abs(total - 2 * pile))
        }
        return best
    }

    @Test("Examples and edge cases", arguments: [
        ([8, 3, 12, 5, 9], 3),
        ([6, 2, 9, 4, 3], 0),
        ([1, 2, 4, 8, 16], 1),
        ([7], 7),
        ([10, 10], 0),
        ([10, 4], 6),
        ([2, 2, 2, 3, 3], 0),
        ([3, 3, 3, 4, 4], 1),
        ([1, 1, 1], 1),
    ] as [([Int], Int)])
    func examples(stones: [Int], expected: Int) {
        #expect(StoneSmashLeftover.smallestRemainder(stones) == expected)
    }

    @Test("Matches the game played every possible way, for up to 6 stones")
    func playedOut() {
        var random = StonesRandom(seed: 1_049)
        for _ in 0..<120 {
            let n = Int.random(in: 1...6, using: &random)
            let stones = (0..<n).map { _ in Int.random(in: 1...12, using: &random) }
            #expect(StoneSmashLeftover.smallestRemainder(stones) == playEveryWay(stones.sorted()), "\(stones)")
        }
    }

    @Test("Matches the best two-pile split on 300 random rows of up to 12 stones")
    func randomSmall() {
        var random = StonesRandom(seed: 1_046)
        for _ in 0..<300 {
            let n = Int.random(in: 1...12, using: &random)
            let stones = (0..<n).map { _ in Int.random(in: 1...60, using: &random) }
            #expect(StoneSmashLeftover.smallestRemainder(stones) == bestSplit(stones), "\(stones)")
        }
    }

    @Test("100 stones up to 1,000 each")
    func large() {
        var random = StonesRandom(seed: 9_999)

        // Every stone twice: the copies balance perfectly
        var doubled = (0..<50).map { _ in Int.random(in: 1...1_000, using: &random) }
        doubled += doubled
        doubled.shuffle(using: &random)
        #expect(StoneSmashLeftover.smallestRemainder(doubled) == 0)

        // Multiples of 4, each twice, plus a 2: a gap of 0 is impossible (half the total is odd, every pile
        // is even) and the copies plus the 2 give a gap of exactly 2
        var fours = (0..<49).map { _ in 4 * Int.random(in: 1...250, using: &random) }
        fours += fours
        fours.append(2)
        fours.shuffle(using: &random)
        #expect(StoneSmashLeftover.smallestRemainder(fours) == 2)

        #expect(StoneSmashLeftover.smallestRemainder(Array(repeating: 1_000, count: 40)) == 0)
        #expect(StoneSmashLeftover.smallestRemainder(Array(repeating: 1_000, count: 21)) == 1_000)
        #expect(StoneSmashLeftover.smallestRemainder([1_000] + Array(repeating: 1, count: 99)) == 901)
    }
}
