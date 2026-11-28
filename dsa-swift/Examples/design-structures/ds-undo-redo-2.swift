// Generated from src/dsa/content/lessons/design-structures/ds-undo-redo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Document {
    var lines: [String] = []
}

/// An edit that knows how to do itself and how to take itself back.
protocol Command {
    var name: String { get }
    func apply(to document: inout Document)
    func revert(on document: inout Document)
}

struct AppendLine: Command {
    let text: String
    var name: String { "append \"\(text)\"" }
    func apply(to document: inout Document) { document.lines.append(text) }
    func revert(on document: inout Document) { document.lines.removeLast() }
}

struct EditLine: Command {
    let index: Int
    let old: String                                // remembered, so the edit can be reverted
    let new: String
    var name: String { "edit line \(index)" }
    func apply(to document: inout Document) { document.lines[index] = new }
    func revert(on document: inout Document) { document.lines[index] = old }
}

struct RemoveLine: Command {
    let index: Int
    let removed: String                            // remembered, so it can be put back
    var name: String { "remove line \(index)" }
    func apply(to document: inout Document) { document.lines.remove(at: index) }
    func revert(on document: inout Document) { document.lines.insert(removed, at: index) }
}

struct History {
    private(set) var document = Document()
    private var undoStack: [any Command] = []
    private var redoStack: [any Command] = []

    private mutating func perform(_ command: any Command) {
        command.apply(to: &document)
        undoStack.append(command)
        redoStack.removeAll()                      // a new edit starts a new future
    }

    mutating func append(_ text: String) {
        perform(AppendLine(text: text))
    }

    mutating func edit(line index: Int, to text: String) {
        perform(EditLine(index: index, old: document.lines[index], new: text))
    }

    mutating func remove(line index: Int) {
        perform(RemoveLine(index: index, removed: document.lines[index]))
    }

    @discardableResult
    mutating func undo() -> Bool {
        guard let command = undoStack.popLast() else { return false }
        command.revert(on: &document)
        redoStack.append(command)
        print("undo", command.name)
        return true
    }

    @discardableResult
    mutating func redo() -> Bool {
        guard let command = redoStack.popLast() else { return false }
        command.apply(to: &document)
        undoStack.append(command)
        print("redo", command.name)
        return true
    }

    var summary: String {
        "\(document.lines)  undo: \(undoStack.count), redo: \(redoStack.count)"
    }
}

var notes = History()
notes.append("buy milk")
notes.append("call Ana")
notes.edit(line: 0, to: "buy oat milk")
print(notes.summary)
notes.undo()
notes.undo()
print(notes.summary)
notes.redo()
print(notes.summary)
notes.remove(line: 0)                              // a new edit: the redo history is gone
print(notes.summary)
print("redo possible:", notes.redo())
notes.undo()
print(notes.summary)
