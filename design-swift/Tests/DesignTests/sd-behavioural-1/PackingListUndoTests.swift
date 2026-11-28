import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PackingListUndoTests {
    typealias Checklist = PackingListUndo.Checklist
    typealias History = PackingListUndo.History

    /// Applies a command, then its inverse, and returns the list after each
    private func roundTrip(_ command: any PackingListUndo.Command, on items: [String]) -> (applied: [String], reverted: [String]) {
        var list = Checklist(items)
        let inverse = command.apply(to: &list)
        let applied = list.items
        _ = inverse?.apply(to: &list)
        return (applied, list.items)
    }

    @Test("Each command makes its change, and its inverse puts the list back")
    func inverses() {
        let start = ["Passport", "Charger", "Socks"]
        #expect(roundTrip(PackingListUndo.Add("Hat"), on: start) == (start + ["Hat"], start))
        #expect(roundTrip(PackingListUndo.Insert("Hat", at: 1), on: start) == (["Passport", "Hat", "Charger", "Socks"], start))
        #expect(roundTrip(PackingListUndo.Insert("Hat", at: 3), on: start) == (start + ["Hat"], start))
        #expect(roundTrip(PackingListUndo.Remove(at: 1), on: start) == (["Passport", "Socks"], start))
        #expect(roundTrip(PackingListUndo.Rename(at: 2, to: "Wool socks"), on: start) == (["Passport", "Charger", "Wool socks"], start))
    }

    @Test("A command that would change nothing returns no inverse and leaves the list alone")
    func noOps() {
        let start = Checklist(["Passport"])
        let commands: [any PackingListUndo.Command] = [
            PackingListUndo.Remove(at: 1),
            PackingListUndo.Remove(at: -1),
            PackingListUndo.Insert("Hat", at: 2),
            PackingListUndo.Rename(at: 0, to: "Passport"),
            PackingListUndo.Rename(at: 4, to: "Hat"),
            PackingListUndo.Batch("Nothing", [PackingListUndo.Remove(at: 9)]),
        ]
        for command in commands {
            var list = start
            #expect(command.apply(to: &list) == nil, "\(command.actionName)")
            #expect(list == start)
        }
        var list = start
        #expect(PackingListUndo.Add("Hat").apply(to: &list) != nil)
    }

    @Test("A batch is undone in reverse order, so removals come back where they were")
    func batchUnwinds() {
        var history = History(Checklist(["Passport", "Charger", "Socks", "Hat"]))
        history.perform(PackingListUndo.Batch("Remove Packed", [PackingListUndo.Remove(at: 0), PackingListUndo.Remove(at: 0), PackingListUndo.Remove(at: 1)]))
        #expect(history.list.items == ["Socks"])
        history.undo()
        #expect(history.list.items == ["Passport", "Charger", "Socks", "Hat"])
        history.redo()
        #expect(history.list.items == ["Socks"])
    }

    @Test("Undo and redo walk back and forward through the changes")
    func undoRedo() {
        var history = History()
        history.perform(PackingListUndo.Add("Passport"))
        history.perform(PackingListUndo.Add("Charger"))
        history.perform(PackingListUndo.Rename(at: 1, to: "USB-C charger"))
        #expect(history.list.items == ["Passport", "USB-C charger"])
        history.undo()
        #expect(history.list.items == ["Passport", "Charger"])
        history.undo()
        history.undo()
        #expect(history.list.items.isEmpty)
        #expect(!history.canUndo)
        history.undo()
        #expect(history.list.items.isEmpty)
        history.redo()
        history.redo()
        history.redo()
        #expect(history.list.items == ["Passport", "USB-C charger"])
        #expect(!history.canRedo)
    }

    @Test("Menus show the original command's name for both undo and redo")
    func actionNames() {
        var history = History()
        #expect(history.undoActionName == nil)
        history.perform(PackingListUndo.Add("Passport"))
        history.perform(PackingListUndo.Remove(at: 0))
        #expect(history.undoActionName == "Remove")
        history.undo()
        #expect(history.undoActionName == "Add Passport")
        #expect(history.redoActionName == "Remove")
        history.undo()
        #expect(history.redoActionName == "Add Passport")
        #expect(history.undoActionName == nil)
    }

    @Test("A new change clears what could be redone")
    func newChangeClearsRedo() {
        var history = History()
        history.perform(PackingListUndo.Add("Passport"))
        history.perform(PackingListUndo.Add("Charger"))
        history.undo()
        #expect(history.canRedo)
        history.perform(PackingListUndo.Add("Socks"))
        #expect(!history.canRedo)
        #expect(history.redoActionName == nil)
        history.redo()
        #expect(history.list.items == ["Passport", "Socks"])
    }

    @Test("A change that does nothing isn't recorded and doesn't clear redo")
    func noOpNotRecorded() {
        var history = History()
        history.perform(PackingListUndo.Add("Passport"))
        history.perform(PackingListUndo.Add("Charger"))
        history.undo()
        history.perform(PackingListUndo.Remove(at: 5))
        #expect(history.canRedo)
        #expect(history.undoActionName == "Add Passport")
        history.redo()
        #expect(history.list.items == ["Passport", "Charger"])
    }
}
