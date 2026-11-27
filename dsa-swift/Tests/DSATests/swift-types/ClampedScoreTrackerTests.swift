import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ClampedScoreTrackerTests {
    typealias Tracker = ClampedScoreTracker.Tracker

    @Test("The maximum is 1,000")
    func maximum() {
        #expect(Tracker.maximum == 1_000)
    }

    @Test("The starting value is clamped too", arguments: [(300, 300), (1_500, 1_000), (-20, 0), (0, 0), (1_000, 1_000)])
    func startingValue(starting: Int, expected: Int) {
        let tracker = Tracker(starting: starting)
        #expect(tracker.current == expected)
        #expect(tracker.best == expected)
        #expect(tracker.changes == 0)
    }

    @Test("A score in range is stored as it is")
    func inRange() {
        var tracker = Tracker(starting: 300)
        tracker.current = 450
        #expect(tracker.current == 450)
        #expect(tracker.best == 450)
        #expect(tracker.changes == 1)
    }

    @Test("Scores above the maximum are clamped")
    func clampHigh() {
        var tracker = Tracker(starting: 300)
        tracker.current = 5_000
        #expect(tracker.current == 1_000)
        #expect(tracker.best == 1_000)
        #expect(tracker.changes == 1)
        tracker.current = 2_000
        #expect(tracker.current == 1_000)
        #expect(tracker.changes == 1, "Clamping back to the same value isn't a change")
    }

    @Test("Scores below zero are clamped")
    func clampLow() {
        var tracker = Tracker(starting: 50)
        tracker.current = -7
        #expect(tracker.current == 0)
        #expect(tracker.best == 50)
        #expect(tracker.changes == 1)
        tracker.current -= 100
        #expect(tracker.current == 0)
        #expect(tracker.changes == 1)
    }

    @Test("best remembers the highest score so far")
    func best() {
        var tracker = Tracker(starting: 0)
        for score in [12, 40, 7, 33] {
            tracker.current = score
        }
        #expect(tracker.current == 33)
        #expect(tracker.best == 40)
        #expect(tracker.changes == 4)
    }

    @Test("Setting the same value again isn't a change")
    func sameValue() {
        var tracker = Tracker(starting: 10)
        tracker.current = 10
        #expect(tracker.changes == 0)
        tracker.current += 5
        tracker.current += 0
        #expect(tracker.current == 15)
        #expect(tracker.changes == 1)
    }

    @Test("replaying starts at 0 and sets each score in turn", arguments: [
        ([12, 40, 7, 33], 33, 40, 4),
        ([], 0, 0, 0),
        ([0, 0, 0], 0, 0, 0),
        ([-5, 2_000, 2_000, 999], 999, 1_000, 2),
        ([1_000, -1, 1_000, -1], 0, 1_000, 4),
    ])
    func replaying(scores: [Int], current: Int, best: Int, changes: Int) {
        let tracker = Tracker.replaying(scores)
        #expect(tracker.current == current)
        #expect(tracker.best == best)
        #expect(tracker.changes == changes)
    }

    @Test("Copies of a tracker are independent")
    func copies() {
        var first = Tracker(starting: 100)
        var second = first
        second.current = 900
        first.current = 200
        #expect(first.best == 200)
        #expect(second.best == 900)
        #expect(first.changes == 1)
        #expect(second.changes == 1)
    }
}
