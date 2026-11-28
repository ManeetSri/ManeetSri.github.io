import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BackoffScheduleTests {
    private func schedule(_ jitter: BackoffSchedule.Jitter, retries: Int = 6, base: Double = 0.5, factor: Double = 2, cap: Double = 4, seed: UInt64 = 7) -> [Double] {
        var generator = SeededGenerator(seed: seed)
        return BackoffSchedule.delays(retries: retries, base: base, factor: factor, cap: cap, jitter: jitter, using: &generator)
    }

    @Test("Without jitter the delays double, then stop at the cap")
    func exponential() {
        #expect(schedule(.none) == [0.5, 1, 2, 4, 4, 4])
        #expect(schedule(.none, retries: 4, base: 1, factor: 3, cap: 100) == [1, 3, 9, 27])
    }

    @Test("No retries means no delays", arguments: [0, -1])
    func noRetries(retries: Int) {
        #expect(schedule(.none, retries: retries).isEmpty)
        #expect(schedule(.full, retries: retries).isEmpty)
    }

    @Test("Full jitter stays between zero and the exponential delay")
    func fullJitter() {
        let exponential: [Double] = [0.5, 1, 2, 4, 4, 4]
        let delays = schedule(.full)
        #expect(delays.count == exponential.count)
        for (delay, limit) in zip(delays, exponential) {
            #expect(delay >= 0 && delay <= limit)
        }
    }

    @Test("Equal jitter keeps at least half the exponential delay")
    func equalJitter() {
        let exponential: [Double] = [0.5, 1, 2, 4, 4, 4]
        let delays = schedule(.equal)
        #expect(delays.count == exponential.count)
        for (delay, limit) in zip(delays, exponential) {
            #expect(delay >= limit / 2 && delay <= limit)
        }
    }

    @Test("Jitter is random, but the same seed gives the same schedule")
    func repeatable() {
        #expect(schedule(.full, seed: 1) == schedule(.full, seed: 1))
        #expect(schedule(.full, seed: 1) != schedule(.full, seed: 2))
        #expect(Set(schedule(.full, retries: 20, cap: 1000)).count > 15)
    }
}
