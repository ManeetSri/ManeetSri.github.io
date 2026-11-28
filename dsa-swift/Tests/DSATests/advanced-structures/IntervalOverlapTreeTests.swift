import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct IntervalRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct IntervalOverlapTreeTests {
    private func timeline() -> IntervalOverlapTree.Tree {
        let tree = IntervalOverlapTree.Tree()
        tree.insert(start: 240, end: 719, id: 1)       // interview
        tree.insert(start: 0, end: 239, id: 2)         // intro
        tree.insert(start: 1_080, end: 1_199, id: 3)   // credits
        tree.insert(start: 0, end: 1_199, id: 4)       // music
        tree.insert(start: 400, end: 520, id: 5)       // b-roll
        tree.insert(start: 0, end: 47, id: 6)          // title
        tree.insert(start: 1_100, end: 1_199, id: 7)   // logo
        return tree
    }

    @Test("The timeline from the statement")
    func statementExamples() {
        let tree = timeline()
        #expect(tree.count == 7)
        #expect(tree.containing(450) == [1, 4, 5])
        #expect(tree.overlapping(start: 700, end: 1_090) == [1, 3, 4])
        #expect(tree.containing(1_200) == [])
        #expect(tree.containing(0) == [2, 4, 6])
        #expect(tree.overlapping(start: -50, end: 2_000) == [1, 2, 3, 4, 5, 6, 7])
    }

    @Test("Closed intervals: touching at one point counts")
    func touching() {
        let tree = IntervalOverlapTree.Tree()
        tree.insert(start: 10, end: 20, id: 1)
        tree.insert(start: 20, end: 30, id: 2)
        tree.insert(start: 31, end: 31, id: 3)
        #expect(tree.containing(20) == [1, 2])
        #expect(tree.overlapping(start: 30, end: 31) == [2, 3])
        #expect(tree.overlapping(start: 21, end: 29) == [2])
        #expect(tree.overlapping(start: 0, end: 9) == [])
        #expect(tree.containing(31) == [3])
    }

    @Test("Equal starts and identical intervals are kept apart by id")
    func duplicates() {
        let tree = IntervalOverlapTree.Tree()
        for id in [5, 1, 9, 3] {
            tree.insert(start: 100, end: 200, id: id)
        }
        tree.insert(start: 100, end: 150, id: 7)
        #expect(tree.containing(175) == [1, 3, 5, 9])
        #expect(tree.containing(100) == [1, 3, 5, 7, 9])
        #expect(tree.remove(id: 3))
        #expect(tree.containing(175) == [1, 5, 9])
        #expect(tree.count == 4)
    }

    @Test("Inserting an existing id or removing a missing one changes nothing")
    func idRules() {
        let tree = IntervalOverlapTree.Tree()
        #expect(tree.insert(start: 1, end: 5, id: 42))
        #expect(!tree.insert(start: 100, end: 200, id: 42))
        #expect(tree.containing(150) == [])
        #expect(tree.containing(3) == [42])
        #expect(!tree.remove(id: 7))
        #expect(tree.count == 1)
        #expect(tree.remove(id: 42))
        #expect(!tree.remove(id: 42))
        #expect(tree.count == 0)
        #expect(tree.containing(3) == [])
        #expect(tree.insert(start: 8, end: 9, id: 42), "a removed id can be used again")
    }

    @Test("Removing keeps the latest-end information right")
    func removeUpdatesMaxEnd() {
        let tree = IntervalOverlapTree.Tree()
        tree.insert(start: 0, end: 1_000, id: 1)        // the only long interval
        for i in 2...50 {
            tree.insert(start: i * 10, end: i * 10 + 5, id: i)
        }
        #expect(tree.containing(997) == [1])
        tree.remove(id: 1)
        #expect(tree.containing(997) == [])
        #expect(tree.containing(23) == [2])
        #expect(tree.overlapping(start: 498, end: 512) == [50])
    }

    @Test("Matches a brute-force scan through random operations", arguments: [1, 2, 3] as [UInt64])
    func matchesBruteForce(seed: UInt64) {
        var random = IntervalRandom(seed: seed)
        let tree = IntervalOverlapTree.Tree()
        var model: [Int: (start: Int, end: Int)] = [:]
        for step in 0..<3_000 {
            let id = Int.random(in: 0..<150, using: &random)
            switch Int.random(in: 0..<10, using: &random) {
            case 0..<4:
                let start = Int.random(in: -500...500, using: &random)
                let end = start + Int.random(in: 0...80, using: &random)
                let expected = model[id] == nil
                if expected { model[id] = (start, end) }
                if tree.insert(start: start, end: end, id: id) != expected {
                    Issue.record("insert(id: \(id)) returned the wrong answer at step \(step)")
                    return
                }
            case 4..<6:
                let expected = model.removeValue(forKey: id) != nil
                if tree.remove(id: id) != expected {
                    Issue.record("remove(id: \(id)) returned the wrong answer at step \(step)")
                    return
                }
            default:
                let start = Int.random(in: -600...600, using: &random)
                let end = start + Int.random(in: 0...60, using: &random)
                let expected = model.filter { $0.value.start <= end && start <= $0.value.end }.keys.sorted()
                if tree.overlapping(start: start, end: end) != expected {
                    Issue.record("overlapping(\(start), \(end)) is wrong at step \(step)")
                    return
                }
            }
            if tree.count != model.count {
                Issue.record("count is wrong at step \(step)")
                return
            }
        }
    }

    @Test("60,000 intervals inserted in order of start")
    func sortedInserts() {
        // Sorted starts turn an unbalanced BST into a chain, so each insert would cost O(n).
        let tree = IntervalOverlapTree.Tree()
        let n = 60_000
        for i in 0..<n {
            tree.insert(start: i * 10, end: i * 10 + 15, id: i)
        }
        #expect(tree.count == n)
        for point in stride(from: 3, to: n * 10, by: 997) {
            // [10i, 10i + 15] contains point when (point - 15) / 10 ≤ i ≤ point / 10
            let low = max(0, (point - 15 + 9) / 10)
            let expected = Array(low...min(n - 1, point / 10))
            if tree.containing(point) != expected {
                Issue.record("containing(\(point)) is wrong")
                return
            }
        }
        #expect(tree.containing(12) == [0, 1])
        #expect(tree.containing(599_999) == [59_999])
        #expect(tree.overlapping(start: 300_000, end: 300_045).count == 6)
        for i in stride(from: 0, to: n, by: 2) {
            tree.remove(id: i)
        }
        #expect(tree.count == n / 2)
        #expect(tree.containing(12) == [1])
        #expect(tree.overlapping(start: 300_000, end: 300_045) == [29_999, 30_001, 30_003])
    }
}
