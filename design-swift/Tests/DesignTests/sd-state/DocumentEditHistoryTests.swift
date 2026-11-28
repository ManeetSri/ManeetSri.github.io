import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DocumentEditHistoryTests {
    typealias History = DocumentEditHistory.History

    /// A tiny drawing: the shapes on a canvas, back to front
    struct Canvas: Equatable, Sendable {
        var shapes: [String] = []
    }

    @Test("Undo steps back through changes and redo steps forward again")
    func undoAndRedo() {
        var history = History("")
        history.apply("Milk", actionName: "Typing")
        history.apply("Milk, eggs", actionName: "Typing")
        #expect(history.current == "Milk, eggs")
        #expect(history.canUndo && !history.canRedo)

        history.undo()
        #expect(history.current == "Milk")
        history.undo()
        #expect(history.current == "")
        #expect(!history.canUndo && history.canRedo)

        history.redo()
        #expect(history.current == "Milk")
        history.redo()
        #expect(history.current == "Milk, eggs")
        #expect(!history.canRedo)
    }

    @Test("Undo and redo with nothing to step to change nothing")
    func nothingToStepTo() {
        var history = History(Canvas(shapes: ["circle"]))
        history.undo()
        history.redo()
        #expect(history.current == Canvas(shapes: ["circle"]))

        history.apply(Canvas(shapes: ["circle", "square"]), actionName: "Add Square")
        history.redo()
        #expect(history.current.shapes == ["circle", "square"])
        history.undo()
        history.undo()
        #expect(history.current.shapes == ["circle"])
    }

    @Test("A new change after an undo throws the redo history away")
    func newChangeClearsRedo() {
        var history = History(Canvas())
        history.apply(Canvas(shapes: ["circle"]), actionName: "Add Circle")
        history.apply(Canvas(shapes: ["circle", "square"]), actionName: "Add Square")
        history.undo()
        #expect(history.canRedo)

        history.apply(Canvas(shapes: ["circle", "star"]), actionName: "Add Star")
        #expect(!history.canRedo)
        history.redo()
        #expect(history.current.shapes == ["circle", "star"])
        history.undo()
        #expect(history.current.shapes == ["circle"])
    }

    @Test("The action names follow the changes, for the Undo and Redo menu items")
    func actionNames() {
        var history = History("Hello")
        #expect(history.undoActionName == nil)
        history.apply("**Hello**", actionName: "Bold")
        history.apply("**Hello** world", actionName: "Paste")
        #expect(history.undoActionName == "Paste")

        history.undo()
        #expect(history.undoActionName == "Bold")
        #expect(history.redoActionName == "Paste")
        history.undo()
        #expect(history.undoActionName == nil)
        #expect(history.redoActionName == "Bold")
    }

    @Test("A change that leaves the document as it was isn't recorded")
    func unchangedDocument() {
        var history = History("Draft")
        history.apply("Draft 2", actionName: "Typing")
        history.undo()
        history.apply("Draft", actionName: "Typing")
        #expect(history.redoActionName == "Typing")
        #expect(!history.canUndo)
        history.redo()
        #expect(history.current == "Draft 2")
    }

    @Test("Coalesced typing is undone in one step")
    func coalescedTyping() {
        var history = History("")
        for text in ["H", "He", "Hel", "Hello"] {
            history.apply(text, actionName: "Typing", coalescing: true)
        }
        history.apply("Hello!", actionName: "Paste")
        #expect(history.current == "Hello!")

        history.undo()
        #expect(history.current == "Hello")
        history.undo()
        #expect(history.current == "")
        #expect(!history.canUndo)
        history.redo()
        #expect(history.current == "Hello")
    }

    @Test("Coalescing never joins changes with different names, or across an undo")
    func coalescingBoundaries() {
        var history = History("")
        history.apply("a", actionName: "Typing", coalescing: true)
        history.apply("ab", actionName: "Typing", coalescing: true)
        history.apply("ab\n", actionName: "New Line", coalescing: true)
        history.undo()
        #expect(history.current == "ab")

        history.apply("abc", actionName: "Typing", coalescing: true)
        history.undo()
        #expect(history.current == "ab")
        history.undo()
        #expect(history.current == "")
    }

    @Test("Only the most recent changes, up to the limit, can be undone")
    func limit() {
        var history = History(0, limit: 2)
        for value in 1...4 {
            history.apply(value, actionName: "Step")
        }
        history.undo()
        history.undo()
        #expect(history.current == 2)
        #expect(!history.canUndo)
        history.redo()
        history.redo()
        #expect(history.current == 4)
    }
}
