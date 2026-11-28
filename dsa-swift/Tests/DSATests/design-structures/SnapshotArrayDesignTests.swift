import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SnapshotArrayDesignTests {
    typealias SnapshotArray = SnapshotArrayDesign.SnapshotArray

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Snapshots remember values that change later")
    func example() {
        var array = SnapshotArray(count: 3)
        #expect(array.count == 3)
        array.set(5, at: 0)
        #expect(array.snapshot() == 0)
        array.set(6, at: 0)
        #expect(array.value(at: 0, snapshot: 0) == 5)
        #expect(array[0] == 6)
        #expect(array.snapshot() == 1)
        #expect(array.value(at: 0, snapshot: 1) == 6)
        #expect(array.value(at: 1, snapshot: 0) == 0)
        #expect(array.value(at: 2, snapshot: 1) == 0)
    }

    @Test("Only the last change before a snapshot counts")
    func lastChangeWins() {
        var array = SnapshotArray(count: 4)
        array.set(1, at: 2)
        array.set(2, at: 2)
        array.set(3, at: 2)
        let id = array.snapshot()
        array.set(4, at: 2)
        #expect(array.value(at: 2, snapshot: id) == 3)
        #expect(array[2] == 4)
    }

    @Test("Snapshots with no changes in between all agree")
    func quietSnapshots() {
        var array = SnapshotArray(count: 2)
        array.set(9, at: 1)
        let ids = [array.snapshot(), array.snapshot(), array.snapshot()]
        #expect(ids == [0, 1, 2])
        for id in 0..<3 {
            #expect(array.value(at: 1, snapshot: id) == 9)
            #expect(array.value(at: 0, snapshot: id) == 0)
        }
    }

    @Test("Setting a value back to an old one is still a change")
    func changeBack() {
        var array = SnapshotArray(count: 1)
        array.set(7, at: 0)
        _ = array.snapshot()
        array.set(0, at: 0)
        _ = array.snapshot()
        array.set(7, at: 0)
        _ = array.snapshot()
        #expect(array.value(at: 0, snapshot: 0) == 7)
        #expect(array.value(at: 0, snapshot: 1) == 0)
        #expect(array.value(at: 0, snapshot: 2) == 7)
    }

    @Test("Thousands of mixed calls match a model that copies everything", arguments: [1, 3, 8])
    func matchesModel(count: Int) {
        var steps = Steps(seed: UInt64(count) &* 37)
        var array = SnapshotArray(count: count)
        var current = Array(repeating: 0, count: count)
        var snapshots: [[Int]] = []
        for step in 0..<4_000 {
            switch steps.next(below: 4) {
            case 0, 1:
                let index = steps.next(below: count)
                let value = steps.next(below: 20) - 10
                array.set(value, at: index)
                current[index] = value
            case 2:
                if array.snapshot() != snapshots.count {
                    Issue.record("snapshot() returned the wrong id at step \(step)")
                    return
                }
                snapshots.append(current)
            default:
                let index = steps.next(below: count)
                if array[index] != current[index] {
                    Issue.record("the current value at \(index) is wrong at step \(step)")
                    return
                }
                guard !snapshots.isEmpty else { continue }
                let id = steps.next(below: snapshots.count)
                if array.value(at: index, snapshot: id) != snapshots[id][index] {
                    Issue.record("value(at: \(index), snapshot: \(id)) is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("50,000 elements and 50,000 snapshots stay fast", .timeLimit(.minutes(1)))
    func large() {
        var steps = Steps(seed: 2_024)
        let count = 50_000
        let tracked = 20                         // indexes 0..<20 are watched in every snapshot
        var array = SnapshotArray(count: count)
        var current = Array(repeating: 0, count: tracked)
        var seen: [[Int]] = []
        for step in 0..<100_000 {
            let index = steps.next(below: 2) == 0 ? steps.next(below: tracked) : steps.next(below: count)
            let value = steps.next(below: 1_000)
            array.set(value, at: index)
            if index < tracked { current[index] = value }
            if step % 2 == 1 {
                _ = array.snapshot()
                seen.append(current)
            }
        }
        var correct = true
        for _ in 0..<100_000 {
            let index = steps.next(below: tracked)
            let id = steps.next(below: seen.count)
            if array.value(at: index, snapshot: id) != seen[id][index] {
                correct = false
                break
            }
        }
        #expect(correct)
        #expect(array.snapshot() == 50_000)
    }
}
