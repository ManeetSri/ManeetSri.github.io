import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LoopNestBoundTests {
    typealias Bound = LoopNestBound.Bound

    @Test("The examples")
    func examples() {
        #expect(LoopNestBound.bound([[.linear, .linear], [.linear]]) == Bound(power: 2, logPower: 0))
        #expect(LoopNestBound.bound([[.sort], [.linear]]) == Bound(power: 1, logPower: 1))
        #expect(LoopNestBound.bound([[.halving, .fixed(100)]]) == Bound(power: 0, logPower: 1))
        #expect(LoopNestBound.bound([[.linear, .sort]]) == Bound(power: 2, logPower: 1))
        #expect(LoopNestBound.bound([[.halving, .halving], [.linear]]) == Bound(power: 1, logPower: 0))
        #expect(LoopNestBound.bound([]) == Bound(power: 0, logPower: 0))
    }

    @Test("Nothing but constants is O(1)")
    func constants() {
        #expect(LoopNestBound.bound([[]]) == Bound(power: 0, logPower: 0))
        #expect(LoopNestBound.bound([[.fixed(1_000_000_000)]]) == Bound(power: 0, logPower: 0))
        #expect(LoopNestBound.bound([[.fixed(3), .fixed(4)], [], [.fixed(26)]]) == Bound(power: 0, logPower: 0))
    }

    @Test("Fixed loops vanish wherever they sit")
    func fixedAnywhere() {
        #expect(LoopNestBound.bound([[.fixed(26), .linear, .fixed(10), .linear]]) == Bound(power: 2, logPower: 0))
        #expect(LoopNestBound.bound([[.linear, .halving, .fixed(1_000)]]) == Bound(power: 1, logPower: 1))
    }

    @Test("The dominant block wins, compared by power first")
    func dominantBlock() {
        // n log² n + n²: n² wins
        #expect(LoopNestBound.bound([[.linear, .halving, .halving], [.linear, .linear]]) == Bound(power: 2, logPower: 0))
        // n² + n² log n: the log breaks the tie
        #expect(LoopNestBound.bound([[.linear, .linear], [.halving, .linear, .linear]]) == Bound(power: 2, logPower: 1))
        // the order of the blocks doesn't matter
        #expect(LoopNestBound.bound([[.linear], [.halving, .halving, .halving, .halving]]) == Bound(power: 1, logPower: 0))
        #expect(LoopNestBound.bound([[.halving, .halving, .halving, .halving], [.linear]]) == Bound(power: 1, logPower: 0))
    }

    @Test("Sorting adds a power of n and a power of log n")
    func sorting() {
        #expect(LoopNestBound.bound([[.sort]]) == Bound(power: 1, logPower: 1))
        #expect(LoopNestBound.bound([[.halving, .sort]]) == Bound(power: 1, logPower: 2))
        #expect(LoopNestBound.bound([[.sort], [.linear, .linear]]) == Bound(power: 2, logPower: 0))
        #expect(LoopNestBound.bound([[.sort], [.linear, .halving]]) == Bound(power: 1, logPower: 1))
    }

    @Test("Deep nests and many blocks")
    func large() {
        let deep: [LoopNestBound.Layer] = Array(repeating: .linear, count: 30) + Array(repeating: .halving, count: 20)
        #expect(LoopNestBound.bound([deep]) == Bound(power: 30, logPower: 20))

        var blocks: [[LoopNestBound.Layer]] = []
        for i in 0..<1_000 {
            blocks.append(Array(repeating: .linear, count: i % 7) + Array(repeating: .halving, count: i % 11))
        }
        // the best block has power 6; among those (i ≡ 6 mod 7), the largest i mod 11 is 10
        #expect(LoopNestBound.bound(blocks) == Bound(power: 6, logPower: 10))
    }
}
