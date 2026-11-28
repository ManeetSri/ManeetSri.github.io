import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BakeryRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BakeryOrderDeadlineTests {
    /// Watch the clock minute by minute: clearly right, and fine while the answer is small
    private func byTheClock(_ bakeTimes: [Int], _ batches: Int) -> Int {
        var minute = 0
        while true {
            minute += 1
            let done = bakeTimes.reduce(0) { $0 + minute / $1 }
            if done >= batches { return minute }
        }
    }

    /// Batches finished by `minute`, stopping at `cap` so huge minutes can't overflow
    private func done(by minute: Int, _ bakeTimes: [Int], cap: Int) -> Int {
        var total = 0
        for time in bakeTimes {
            total += minute / time
            if total >= cap { return cap }
        }
        return total
    }

    @Test("Examples and small cases", arguments: [
        ([3, 5], 4, 9),
        ([2], 5, 10),
        ([4, 4, 4], 3, 4),
        ([7, 2, 9], 10, 14),
        ([1, 1_000_000], 1, 1),
        ([5], 1, 5),
        ([6, 4, 10], 7, 16),
    ] as [([Int], Int, Int)])
    func examples(bakeTimes: [Int], batches: Int, expected: Int) {
        #expect(BakeryOrderDeadline.earliestMinute(bakeTimes: bakeTimes, batches: batches) == expected)
    }

    @Test("Matches watching the clock, on 400 small bakeries")
    func randomSmall() {
        var random = BakeryRandom(seed: 259)
        for _ in 0..<400 {
            let ovens = (0..<Int.random(in: 1...5, using: &random)).map { _ in Int.random(in: 1...12, using: &random) }
            let batches = Int.random(in: 1...40, using: &random)
            #expect(BakeryOrderDeadline.earliestMinute(bakeTimes: ovens, batches: batches) == byTheClock(ovens, batches))
        }
    }

    @Test("100,000 ovens and an order of 10^12 batches")
    func large() {
        var random = BakeryRandom(seed: 2_259)
        let batches = 1_000_000_000_000
        let ovens = (0..<100_000).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        let answer = BakeryOrderDeadline.earliestMinute(bakeTimes: ovens, batches: batches)
        #expect(done(by: answer, ovens, cap: batches) == batches)
        #expect(done(by: answer - 1, ovens, cap: batches) < batches)

        // Mostly one-minute ovens and one very slow one: careless counting overflows here
        let mixed = [1_000_000] + Array(repeating: 1, count: 99_999)
        let mixedAnswer = BakeryOrderDeadline.earliestMinute(bakeTimes: mixed, batches: batches)
        #expect(done(by: mixedAnswer, mixed, cap: batches) == batches)
        #expect(done(by: mixedAnswer - 1, mixed, cap: batches) < batches)
    }

    @Test("Planted answers at the extremes")
    func extremes() {
        let batches = 1_000_000_000_000
        #expect(BakeryOrderDeadline.earliestMinute(bakeTimes: Array(repeating: 1, count: 100_000), batches: batches) == 10_000_000)
        #expect(BakeryOrderDeadline.earliestMinute(bakeTimes: [1_000_000], batches: batches) == 1_000_000_000_000_000_000)
        #expect(BakeryOrderDeadline.earliestMinute(bakeTimes: Array(repeating: 1_000_000, count: 100_000), batches: 1) == 1_000_000)
    }
}
