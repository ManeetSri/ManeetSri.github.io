import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DrySpellRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// The longest run of `false` in a slice, by walking it.
private func longestDryWalk(_ days: ArraySlice<Bool>) -> Int {
    var best = 0, current = 0
    for rainy in days {
        current = rainy ? 0 : current + 1
        best = max(best, current)
    }
    return best
}

/// The summary a fast reference keeps per block of days, for DSAKit's SegmentTree, which has its own
/// tests: the block's length, its dry runs touching each end, and its best dry run.
private struct DryBlock {
    var length = 0, fromStart = 0, toEnd = 0, best = 0

    init() {}

    init(rainy: Bool) {
        length = 1
        if !rainy { fromStart = 1; toEnd = 1; best = 1 }
    }

    static func join(_ a: DryBlock, _ b: DryBlock) -> DryBlock {
        var joined = DryBlock()
        joined.length = a.length + b.length
        joined.fromStart = a.fromStart < a.length ? a.fromStart : a.length + b.fromStart
        joined.toEnd = b.toEnd < b.length ? b.toEnd : b.length + a.toEnd
        joined.best = max(a.best, b.best, a.toEnd + b.fromStart)
        return joined
    }
}

@Suite struct LongestDrySpellTests {
    @Test("The example from the statement")
    func example() {
        // Days:   0     1      2      3      4     5      6      7
        var log = LongestDrySpell.Log([true, false, false, true, false, false, false, true])
        #expect(log.longestDryRun(from: 0, through: 7) == 3)
        #expect(log.longestDryRun(from: 0, through: 3) == 2)
        #expect(log.longestDryRun(from: 5, through: 7) == 2)
        log.setRainy(false, on: 3)
        #expect(log.longestDryRun(from: 0, through: 7) == 6)
        #expect(log.longestDryRun(from: 2, through: 4) == 3)
        log.setRainy(true, on: 5)
        #expect(log.longestDryRun(from: 0, through: 7) == 4)
    }

    @Test("All dry, all rainy, and a single day")
    func extremes() {
        var dry = LongestDrySpell.Log(Array(repeating: false, count: 10))
        #expect(dry.longestDryRun(from: 0, through: 9) == 10)
        #expect(dry.longestDryRun(from: 3, through: 6) == 4)
        dry.setRainy(true, on: 0)
        dry.setRainy(true, on: 9)
        #expect(dry.longestDryRun(from: 0, through: 9) == 8)

        let wet = LongestDrySpell.Log(Array(repeating: true, count: 7))
        #expect(wet.longestDryRun(from: 0, through: 6) == 0)
        #expect(wet.longestDryRun(from: 2, through: 2) == 0)

        var single = LongestDrySpell.Log([false])
        #expect(single.longestDryRun(from: 0, through: 0) == 1)
        single.setRainy(true, on: 0)
        #expect(single.longestDryRun(from: 0, through: 0) == 0)
    }

    @Test("A run that crosses many blocks is still found")
    func crossingRun() {
        var days = Array(repeating: true, count: 37)
        for day in 5...30 { days[day] = false }
        var log = LongestDrySpell.Log(days)
        #expect(log.longestDryRun(from: 0, through: 36) == 26)
        #expect(log.longestDryRun(from: 6, through: 29) == 24)
        #expect(log.longestDryRun(from: 20, through: 36) == 11)
        log.setRainy(true, on: 17)
        #expect(log.longestDryRun(from: 0, through: 36) == 13)
        log.setRainy(false, on: 17)
        log.setRainy(false, on: 31)
        #expect(log.longestDryRun(from: 0, through: 36) == 27)
    }

    @Test("Matches walking the days on 300 small random logs")
    func randomSmall() {
        var random = DrySpellRandom(seed: 61)
        for _ in 0..<300 {
            let count = Int.random(in: 1...14, using: &random)
            var days = (0..<count).map { _ in Int.random(in: 0..<3, using: &random) == 0 }
            var log = LongestDrySpell.Log(days)
            for _ in 0..<40 {
                if Bool.random(using: &random) {
                    let day = Int.random(in: 0..<count, using: &random)
                    let rainy = Int.random(in: 0..<3, using: &random) == 0
                    days[day] = rainy
                    log.setRainy(rainy, on: day)
                } else {
                    let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
                    let start = min(a, b), end = max(a, b)
                    #expect(log.longestDryRun(from: start, through: end) == longestDryWalk(days[start...end]))
                }
            }
        }
    }

    @Test("100,000 days with 100,000 corrections and questions")
    func large() {
        // Walking each range would visit about 3 × 10⁹ days. The reference is DSAKit's SegmentTree
        // with a block summary of its own.
        var random = DrySpellRandom(seed: 2_027)
        let count = 100_000
        let days = (0..<count).map { _ in Int.random(in: 0..<50, using: &random) == 0 }
        var log = LongestDrySpell.Log(days)
        var reference = SegmentTree(days.map { DryBlock(rainy: $0) }, identity: DryBlock(), merge: DryBlock.join)
        var mismatches = 0
        for step in 0..<100_000 {
            if step % 2 == 0 {
                let day = Int.random(in: 0..<count, using: &random)
                let rainy = Int.random(in: 0..<40, using: &random) == 0
                log.setRainy(rainy, on: day)
                reference.update(at: day, to: DryBlock(rainy: rainy))
            } else {
                let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
                let start = min(a, b), end = max(a, b)
                if log.longestDryRun(from: start, through: end) != reference.query(start...end).best {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }
}
