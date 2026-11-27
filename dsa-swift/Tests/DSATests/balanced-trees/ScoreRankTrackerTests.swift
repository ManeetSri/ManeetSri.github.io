import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ScoreRankTrackerTests {
    typealias Tracker = ScoreRankTracker.Tracker

    /// Counts of scores 0..<size in a Fenwick tree: the test's own fast model for the large test.
    private struct ScoreCounts {
        private var tree: [Int]

        init(size: Int) {
            tree = Array(repeating: 0, count: size + 1)
        }

        mutating func add(_ score: Int) {
            var i = score + 1
            while i < tree.count {
                tree[i] += 1
                i += i & -i
            }
        }

        func countAtMost(_ score: Int) -> Int {
            var i = min(score + 1, tree.count - 1)
            var total = 0
            while i > 0 {
                total += tree[i]
                i -= i & -i
            }
            return total
        }
    }

    @Test("The statement's example")
    func example() {
        let tracker = Tracker()
        for score in [50, 20, 70, 20] {
            tracker.record(score)
        }
        #expect(tracker.count == 4)
        #expect(tracker.countAtMost(0) == 0)
        #expect(tracker.countAtMost(20) == 2)
        #expect(tracker.countAtMost(49) == 2)
        #expect(tracker.countAtMost(50) == 3)
        #expect(tracker.countAtMost(100) == 4)
        #expect([1, 2, 3, 4].map { tracker.kthSmallest($0) } == [20, 20, 50, 70])
        #expect(tracker.kthSmallest(0) == nil)
        #expect(tracker.kthSmallest(5) == nil)
    }

    @Test("An empty tracker")
    func empty() {
        let tracker = Tracker()
        #expect(tracker.count == 0)
        #expect(tracker.countAtMost(10) == 0)
        #expect(tracker.kthSmallest(1) == nil)
    }

    @Test("Negative scores, extremes and many repeats")
    func extremes() {
        let tracker = Tracker()
        for score in [-5, Int.max, -5, Int.min, 0, -5] {
            tracker.record(score)
        }
        #expect(tracker.countAtMost(Int.min) == 1)
        #expect(tracker.countAtMost(-6) == 1)
        #expect(tracker.countAtMost(-5) == 4)
        #expect(tracker.countAtMost(Int.max - 1) == 5)
        #expect(tracker.countAtMost(Int.max) == 6)
        #expect((1...6).map { tracker.kthSmallest($0) } == [Int.min, -5, -5, -5, 0, Int.max])
        for _ in 0..<1_000 {
            tracker.record(7)
        }
        #expect(tracker.count == 1_006)
        #expect(tracker.countAtMost(7) == 1_005)
        #expect(tracker.kthSmallest(1_005) == 7)
        #expect(tracker.kthSmallest(1_006) == Int.max)
    }

    @Test("Matches a sorted array on small random input")
    func againstSortedArray() {
        var state: UInt64 = 3
        func next(_ limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
        let tracker = Tracker()
        var sorted: [Int] = []
        var wrong = 0
        for _ in 0..<2_000 {
            let score = next(400) - 200
            tracker.record(score)
            sorted.insert(score, at: sorted.firstIndex { $0 > score } ?? sorted.count)
            let query = next(440) - 220
            if tracker.countAtMost(query) != sorted.filter({ $0 <= query }).count { wrong += 1 }
            let k = next(sorted.count + 2)
            let expected = k >= 1 && k <= sorted.count ? sorted[k - 1] : nil
            if tracker.kthSmallest(k) != expected { wrong += 1 }
        }
        #expect(wrong == 0)
        #expect(tracker.count == sorted.count)
    }

    @Test("200,000 scores in a scrambled order, with a query after each")
    func large() {
        let range = 100_000
        let tracker = Tracker()
        var model = ScoreCounts(size: range)
        var wrong = 0
        for i in 0..<(2 * range) {
            let score = (i * 7_919) % range                    // every score twice, in a scrambled order
            tracker.record(score)
            model.add(score)
            let query = (i * 4_099) % range
            if tracker.countAtMost(query) != model.countAtMost(query) { wrong += 1 }
        }
        #expect(wrong == 0)
        #expect(tracker.count == 2 * range)
        // Now each score appears twice, so the kth smallest is (k - 1) / 2
        for k in stride(from: 1, through: 2 * range, by: 37) where tracker.kthSmallest(k) != (k - 1) / 2 {
            wrong += 1
        }
        #expect(wrong == 0)
        #expect(tracker.kthSmallest(2 * range) == range - 1)
    }
}
