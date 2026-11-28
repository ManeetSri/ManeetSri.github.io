import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MinimumPrintSpeedTests {
    /// A tiny deterministic generator, so the random-looking tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Minutes needed at `speed`, worked out independently of the solution.
    private func minutesNeeded(_ jobs: [Int], speed: Int) -> Int {
        jobs.reduce(0) { total, pages in total + pages / speed + (pages % speed == 0 ? 0 : 1) }
    }

    /// Tries every speed from 1 upwards: fine for small jobs.
    private func bruteForce(_ jobs: [Int], _ minutes: Int) -> Int {
        var speed = 1
        while minutesNeeded(jobs, speed: speed) > minutes { speed += 1 }
        return speed
    }

    @Test("Finds the slowest speed in the examples", arguments: [
        ([10, 3, 7], 5, 5),
        ([10, 3, 7], 3, 10),
        ([30, 11, 23, 4, 20], 6, 23),
        ([5, 9, 4, 12], 7, 5),
        ([1, 1, 1, 1], 4, 1),
        ([1_000_000_000], 2, 500_000_000),
    ])
    func examples(jobs: [Int], minutes: Int, expected: Int) {
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: jobs, minutes: minutes) == expected)
    }

    @Test("With one minute per job, the speed must match the largest job")
    func tightestLimit() {
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: [8, 2, 15, 6], minutes: 4) == 15)
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: [7], minutes: 1) == 7)
    }

    @Test("With plenty of time, speed 1 is enough")
    func plentyOfTime() {
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: [8, 2, 15, 6], minutes: 31) == 1)
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: [8, 2, 15, 6], minutes: 1_000_000_000) == 1)
        #expect(MinimumPrintSpeed.slowestSpeed(jobs: [8, 2, 15, 6], minutes: 30) == 2)
    }

    @Test("Matches trying every speed on many small inputs")
    func matchesBruteForce() {
        var steps = Steps(seed: 29)
        var firstMismatch: String? = nil
        for _ in 0..<400 {
            let jobs = (0..<(steps.next(below: 6) + 1)).map { _ in steps.next(below: 40) + 1 }
            let minutes = jobs.count + steps.next(below: 60)
            if MinimumPrintSpeed.slowestSpeed(jobs: jobs, minutes: minutes) != bruteForce(jobs, minutes) {
                firstMismatch = firstMismatch ?? "\(jobs) in \(minutes) minutes"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 100,000 jobs of up to a billion pages")
    func large() {
        var steps = Steps(seed: 2_029)
        let jobs = (0..<100_000).map { _ in steps.next(below: 1_000_000_000) + 1 }
        for minutes in [100_000, 150_000, 1_000_000, 987_654_321] {
            let speed = MinimumPrintSpeed.slowestSpeed(jobs: jobs, minutes: minutes)
            #expect(speed >= 1)
            guard speed >= 1 else { continue }
            #expect(minutesNeeded(jobs, speed: speed) <= minutes, "speed \(speed) should finish in time")
            #expect(speed == 1 || minutesNeeded(jobs, speed: speed - 1) > minutes, "speed \(speed - 1) should be too slow")
        }
    }
}
