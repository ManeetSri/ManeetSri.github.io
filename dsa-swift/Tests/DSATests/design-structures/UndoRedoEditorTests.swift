import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UndoRedoEditorTests {
    typealias Editor = UndoRedoEditor.Editor

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious memory-hungry version: a copy of the whole text before every edit.
    private struct Model {
        let limit: Int
        var text: [Character] = []
        var undoTexts: [[Character]] = []
        var redoTexts: [[Character]] = []

        mutating func edit(to newText: [Character]) {
            undoTexts.append(text)
            if undoTexts.count > limit { undoTexts.removeFirst() }
            redoTexts.removeAll()
            text = newText
        }

        mutating func undo() -> Bool {
            guard let previous = undoTexts.popLast() else { return false }
            redoTexts.append(text)
            text = previous
            return true
        }

        mutating func redo() -> Bool {
            guard let next = redoTexts.popLast() else { return false }
            undoTexts.append(text)
            text = next
            return true
        }
    }

    @Test("Undo steps back through edits and redo steps forward again")
    func example() {
        var editor = Editor()
        editor.insert("Hello", at: 0)
        editor.insert(", world", at: 5)
        #expect(editor.text == "Hello, world")
        editor.delete(from: 5, count: 7)
        #expect(editor.text == "Hello")
        #expect(editor.undo() == true)
        #expect(editor.text == "Hello, world")
        #expect(editor.undo() == true)
        #expect(editor.text == "Hello")
        #expect(editor.redo() == true)
        #expect(editor.text == "Hello, world")
        editor.insert("!", at: 12)
        #expect(editor.text == "Hello, world!")
        #expect(!editor.canRedo)
        #expect(editor.redo() == false, "a new edit throws away what could have been redone")
    }

    @Test("A new editor has nothing to undo or redo")
    func fresh() {
        var editor = Editor()
        #expect(editor.text == "")
        #expect(!editor.canUndo)
        #expect(!editor.canRedo)
        #expect(editor.undo() == false)
        #expect(editor.redo() == false)
    }

    @Test("Empty inserts and zero-length deletes aren't edits")
    func noOpEdits() {
        var editor = Editor()
        editor.insert("", at: 0)
        editor.delete(from: 0, count: 0)
        #expect(!editor.canUndo)
        editor.insert("abc", at: 0)
        editor.insert("", at: 1)
        editor.delete(from: 2, count: 0)
        #expect(editor.undo() == true)
        #expect(editor.text == "")
        #expect(!editor.canUndo)
    }

    @Test("Edits in the middle undo and redo exactly")
    func middleEdits() {
        var editor = Editor()
        editor.insert("let x = 1", at: 0)
        editor.insert("var", at: 0)
        editor.delete(from: 3, count: 3)
        #expect(editor.text == "var x = 1")
        editor.insert("42", at: 8)
        editor.delete(from: 10, count: 1)
        #expect(editor.text == "var x = 42")
        #expect(editor.undo() == true)
        #expect(editor.text == "var x = 421")
        #expect(editor.undo() == true)
        #expect(editor.undo() == true)
        #expect(editor.text == "varlet x = 1")
        #expect(editor.redo() == true)
        #expect(editor.redo() == true)
        #expect(editor.redo() == true)
        #expect(editor.text == "var x = 42")
        #expect(editor.redo() == false)
    }

    @Test("undoLimit keeps only the most recent edits")
    func limit() {
        var editor = Editor(undoLimit: 2)
        editor.insert("a", at: 0)
        editor.insert("b", at: 1)
        editor.insert("c", at: 2)
        #expect(editor.undo() == true)
        #expect(editor.undo() == true)
        #expect(editor.text == "a")
        #expect(editor.undo() == false, "the first edit fell off the history")
        #expect(editor.redo() == true)
        #expect(editor.redo() == true)
        #expect(editor.text == "abc")

        var noHistory = Editor(undoLimit: 0)
        noHistory.insert("text", at: 0)
        #expect(noHistory.text == "text")
        #expect(!noHistory.canUndo)
        #expect(noHistory.undo() == false)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = Editor()
        original.insert("one", at: 0)
        var copy = original
        copy.insert(" two", at: 3)
        #expect(original.text == "one")
        #expect(original.undo() == true)
        #expect(original.text == "")
        #expect(copy.text == "one two")
    }

    @Test("Thousands of mixed calls match a model that copies the text", arguments: [0, 1, 3, Int.max])
    func matchesModel(limit: Int) {
        var steps = Steps(seed: UInt64(limit % 1_000 + 7))
        var editor = Editor(undoLimit: limit)
        var model = Model(limit: limit)
        let pieces: [String] = ["a", "bc", "def", " ", "Swift", "!", ""]
        for step in 0..<4_000 {
            switch steps.next(below: 6) {
            case 0, 1:
                let piece = pieces[steps.next(below: pieces.count)]
                let offset = steps.next(below: model.text.count + 1)
                editor.insert(piece, at: offset)
                if !piece.isEmpty {
                    var newText = model.text
                    newText.insert(contentsOf: piece, at: offset)
                    model.edit(to: newText)
                }
            case 2:
                let offset = steps.next(below: model.text.count + 1)
                let count = steps.next(below: model.text.count - offset + 1)
                editor.delete(from: offset, count: count)
                if count > 0 {
                    var newText = model.text
                    newText.removeSubrange(offset..<offset + count)
                    model.edit(to: newText)
                }
            case 3, 4:
                if editor.undo() != model.undo() {
                    Issue.record("undo() returned the wrong answer at step \(step)")
                    return
                }
            default:
                if editor.redo() != model.redo() {
                    Issue.record("redo() returned the wrong answer at step \(step)")
                    return
                }
            }
            if editor.text != String(model.text) || editor.canUndo != !model.undoTexts.isEmpty || editor.canRedo != !model.redoTexts.isEmpty {
                Issue.record("the text or history is wrong at step \(step)")
                return
            }
        }
    }

    @Test("100,000 edits undo and redo without copying the text", .timeLimit(.minutes(1)))
    func large() {
        var editor = Editor()
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        var expected = ""
        for index in 0..<100_000 {
            let letter = String(letters[index % 26])
            editor.insert(letter, at: index)
            expected += letter
        }
        #expect(editor.text == expected)
        var undone = 0
        while undone < 100_001 && editor.undo() {
            undone += 1
        }
        #expect(undone == 100_000)
        #expect(editor.text == "")
        var redone = 0
        while redone < 100_001 && editor.redo() {
            redone += 1
        }
        #expect(redone == 100_000)
        #expect(editor.text == expected)
    }
}
