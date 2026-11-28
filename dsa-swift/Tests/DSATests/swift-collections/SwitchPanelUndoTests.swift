import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SwitchPanelUndoTests {
    @Test("Records a snapshot after every operation")
    func example() {
        let result = SwitchPanelUndo.history(switchCount: 3, operations: [0, 2, -1, 1, -1, -1, -1])
        #expect(result == [
            [true, false, false],
            [true, false, true],
            [true, false, false],
            [true, true, false],
            [true, false, false],
            [false, false, false],
            [false, false, false],
        ])
    }

    @Test("Earlier snapshots don't change when later switches flip")
    func snapshotsAreIndependent() {
        let result = SwitchPanelUndo.history(switchCount: 3, operations: [0, 1, 2])
        #expect(result == [
            [true, false, false],
            [true, true, false],
            [true, true, true],
        ])
    }

    @Test("Flipping the same switch twice turns it back off")
    func flipTwice() {
        #expect(SwitchPanelUndo.history(switchCount: 2, operations: [1, 1]) == [[false, true], [false, false]])
    }

    @Test("Undo with nothing to undo changes nothing")
    func undoNothing() {
        #expect(SwitchPanelUndo.history(switchCount: 2, operations: [-1, 0]) == [[false, false], [true, false]])
        #expect(SwitchPanelUndo.history(switchCount: 1, operations: [-1, -1, -1]) == [[false], [false], [false]])
    }

    @Test("Undo reverses a flip that turned a switch off")
    func undoTurnOff() {
        let result = SwitchPanelUndo.history(switchCount: 2, operations: [0, 0, -1, -1])
        #expect(result == [[true, false], [false, false], [true, false], [false, false]])
    }

    @Test("Flips after an undo can be undone too")
    func flipAfterUndo() {
        let result = SwitchPanelUndo.history(switchCount: 3, operations: [0, 1, -1, 2, -1, -1, 2])
        #expect(result == [
            [true, false, false],
            [true, true, false],
            [true, false, false],
            [true, false, true],
            [true, false, false],
            [false, false, false],
            [false, false, true],
        ])
    }

    @Test("No operations gives no snapshots")
    func noOperations() {
        #expect(SwitchPanelUndo.history(switchCount: 4, operations: []) == [])
    }

    @Test("Matches a step-by-step model on 1,000 operations and 100 switches")
    func large() throws {
        let switchCount = 100
        let operations = (0..<1_000).map { $0 % 7 == 3 || $0 % 11 == 5 ? -1 : ($0 * 37) % switchCount }
        var panel = Array(repeating: false, count: switchCount)
        var flipped: [Int] = []
        var expected: [[Bool]] = []
        for operation in operations {
            if operation == -1 {
                if let last = flipped.popLast() {
                    panel[last] = !panel[last]
                }
            } else {
                panel[operation] = !panel[operation]
                flipped.append(operation)
            }
            expected.append(panel)
        }
        let result = SwitchPanelUndo.history(switchCount: switchCount, operations: operations)
        try #require(result.count == expected.count)
        #expect(result == expected)
    }
}
