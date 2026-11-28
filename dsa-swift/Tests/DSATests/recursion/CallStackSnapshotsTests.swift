import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CallStackSnapshotsTests {
    // How many calls probe(n) makes
    static func calls(_ n: Int) -> Int {
        n == 0 ? 1 : 1 + calls(n / 2) + calls(n / 3)
    }

    @Test("Snapshot examples")
    func snapshotExamples() {
        #expect(CallStackSnapshots.snapshots(0) == [[0]])
        #expect(CallStackSnapshots.snapshots(1) == [[1], [1, 0], [1, 0]])
        #expect(CallStackSnapshots.snapshots(2) == [[2], [2, 1], [2, 1, 0], [2, 1, 0], [2, 0]])
        #expect(CallStackSnapshots.snapshots(3) == [[3], [3, 1], [3, 1, 0], [3, 1, 0], [3, 1], [3, 1, 0], [3, 1, 0]])
    }

    @Test("The thirteen snapshots of probe(6)")
    func snapshotsOfSix() {
        let expected = [
            [6], [6, 3], [6, 3, 1], [6, 3, 1, 0], [6, 3, 1, 0], [6, 3, 1], [6, 3, 1, 0],
            [6, 3, 1, 0], [6, 2], [6, 2, 1], [6, 2, 1, 0], [6, 2, 1, 0], [6, 2, 0],
        ]
        #expect(CallStackSnapshots.snapshots(6) == expected)
    }

    @Test("Return order examples")
    func returnExamples() {
        #expect(CallStackSnapshots.returnOrder(0) == [0])
        #expect(CallStackSnapshots.returnOrder(1) == [0, 0, 1])
        #expect(CallStackSnapshots.returnOrder(2) == [0, 0, 1, 0, 2])
        #expect(CallStackSnapshots.returnOrder(3) == [0, 0, 1, 0, 0, 1, 3])
        #expect(CallStackSnapshots.returnOrder(6) == [0, 0, 1, 0, 0, 1, 3, 0, 0, 1, 0, 2, 6])
    }

    @Test("One snapshot and one return per call", arguments: [5, 17, 100, 1_000, 10_000])
    func counts(n: Int) {
        let snapshots = CallStackSnapshots.snapshots(n)
        let order = CallStackSnapshots.returnOrder(n)
        #expect(snapshots.count == Self.calls(n))
        #expect(order.count == Self.calls(n))
        #expect(order.last == n, "the first call returns last")
    }

    @Test("Every snapshot is one path: each frame's argument comes from the one below", arguments: [100, 1_000, 10_000])
    func snapshotsArePaths(n: Int) {
        let snapshots = CallStackSnapshots.snapshots(n)
        #expect(snapshots.first == [n])
        var valid = true
        for stack in snapshots {
            for (below, above) in zip(stack, stack.dropFirst()) where above != below / 2 && above != below / 3 {
                valid = false
            }
        }
        // a new call is pushed on top of some frame already on the stack
        for (earlier, later) in zip(snapshots, snapshots.dropFirst()) {
            if later.isEmpty || later.count > earlier.count + 1 || Array(later.dropLast()) != Array(earlier.prefix(later.count - 1)) {
                valid = false
            }
        }
        #expect(valid)
        #expect(snapshots.map(\.count).max() == (n == 10_000 ? 15 : n == 1_000 ? 11 : 8))
    }
}
