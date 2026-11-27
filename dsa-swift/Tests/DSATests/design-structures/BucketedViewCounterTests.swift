import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BucketedViewCounterTests {
    typealias Counter = BucketedViewCounter.Counter

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Counts only the views inside the window")
    func example() {
        var counter = Counter(window: 5)
        counter.record(at: 1)
        counter.record(at: 2)
        counter.record(4, at: 2)
        counter.record(at: 6)
        #expect(counter.count(at: 6) == 6)      // seconds 2 to 6
        #expect(counter.count(at: 7) == 1)      // seconds 3 to 7: only the view at 6
        #expect(counter.count(at: 10) == 1)
        #expect(counter.count(at: 11) == 0)
    }

    @Test("A new counter counts nothing")
    func empty() {
        var counter = Counter(window: 300)
        #expect(counter.count(at: 0) == 0)
        #expect(counter.count(at: 1_000) == 0)
    }

    @Test("Views at the current second count straight away")
    func sameSecond() {
        var counter = Counter(window: 60)
        #expect(counter.count(at: 100) == 0)
        counter.record(at: 100)
        #expect(counter.count(at: 100) == 1)
        counter.record(9, at: 100)
        #expect(counter.count(at: 100) == 10)
        #expect(counter.count(at: 159) == 10)
        #expect(counter.count(at: 160) == 0)
    }

    @Test("A window of one second counts only the current second")
    func windowOfOne() {
        var counter = Counter(window: 1)
        counter.record(3, at: 5)
        #expect(counter.count(at: 5) == 3)
        counter.record(2, at: 6)
        #expect(counter.count(at: 6) == 2)
        #expect(counter.count(at: 7) == 0)
    }

    @Test("A long gap empties the window")
    func longGap() {
        var counter = Counter(window: 300)
        counter.record(50, at: 0)
        counter.record(7, at: 1_000_000_000)
        #expect(counter.count(at: 1_000_000_000) == 7)
        #expect(counter.count(at: 1_000_000_299) == 7)
        #expect(counter.count(at: 1_000_000_300) == 0)
    }

    @Test("Thousands of mixed calls match a simple model", arguments: [1, 3, 60])
    func matchesModel(window: Int) {
        var steps = Steps(seed: UInt64(window) &* 131)
        var counter = Counter(window: window)
        var views: [Int: Int] = [:]
        var time = 0
        for step in 0..<6_000 {
            time += steps.next(below: 4)
            if steps.next(below: 2) == 0 {
                let amount = 1 + steps.next(below: 1_000)
                counter.record(amount, at: time)
                views[time, default: 0] += amount
            } else {
                var expected = 0
                for second in max(0, time - window + 1)...time {
                    expected += views[second, default: 0]
                }
                if counter.count(at: time) != expected {
                    Issue.record("count(at: \(time)) is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("Millions of views in one call still cost O(1)", .timeLimit(.minutes(1)))
    func hugeBatches() {
        var counter = Counter(window: 3_600)
        var correct = true
        for second in 0..<20_000 {
            counter.record(1_000_000, at: second)
            if second % 7 == 0 && counter.count(at: second) != 1_000_000 * min(second + 1, 3_600) {
                correct = false
            }
        }
        #expect(correct)
        #expect(counter.count(at: 22_000) == 1_000_000 * 1_599)
    }

    @Test("A busy stream over 200,000 seconds")
    func large() {
        var steps = Steps(seed: 99)
        let window = 300
        var counter = Counter(window: window)
        var prefix = [0]                         // prefix[s + 1] = views from second 0 to s
        var correct = true
        for second in 0..<200_000 {
            let amount = 1 + steps.next(below: 5)
            counter.record(amount, at: second)
            prefix.append(prefix[second] + amount)
            let expected = prefix[second + 1] - prefix[max(0, second + 1 - window)]
            if counter.count(at: second) != expected {
                correct = false
                break
            }
        }
        #expect(correct)
    }
}
