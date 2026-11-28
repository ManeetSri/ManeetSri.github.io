// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-memento.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Canvas {
    var strokes: [String] = []
    var colour = "black"
}

// The originator: it makes mementos of itself and restores from them
final class Sketch {
    struct Memento {
        fileprivate let canvas: Canvas   // in an app, only Sketch's file can read this
    }

    private(set) var canvas = Canvas()

    func draw(_ stroke: String) { canvas.strokes.append(stroke) }
    func save() -> Memento { Memento(canvas: canvas) }
    func restore(_ memento: Memento) { canvas = memento.canvas }
}

// The caretaker: it keeps mementos and never looks inside them
struct History {
    let limit: Int
    private var undoStack: [Sketch.Memento] = []
    private var redoStack: [Sketch.Memento] = []

    init(limit: Int) {
        self.limit = limit
    }

    mutating func willChange(from current: Sketch.Memento) {
        undoStack.append(current)
        if undoStack.count > limit { undoStack.removeFirst() }
        redoStack.removeAll()   // a new edit starts a new branch
    }

    mutating func undo(from current: Sketch.Memento) -> Sketch.Memento? {
        guard let previous = undoStack.popLast() else { return nil }
        redoStack.append(current)
        return previous
    }

    var canRedo: Bool { !redoStack.isEmpty }

    mutating func redo(from current: Sketch.Memento) -> Sketch.Memento? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(current)
        return next
    }
}

let sketch = Sketch()
var history = History(limit: 3)

@MainActor func draw(_ stroke: String) {
    history.willChange(from: sketch.save())
    sketch.draw(stroke)
}

for stroke in ["sun", "hill", "tree", "house"] { draw(stroke) }
print("drawn:", sketch.canvas.strokes)

while let previous = history.undo(from: sketch.save()) {
    sketch.restore(previous)
}
print("undo all:", sketch.canvas.strokes, "(the limit of 3 dropped the oldest step)")

if let next = history.redo(from: sketch.save()) { sketch.restore(next) }
print("redo:", sketch.canvas.strokes)

draw("river")
print("new edit:", sketch.canvas.strokes, "· can redo:", history.canRedo)

// A struct that holds class instances copies the references, not the objects
final class Layer {
    var name: String
    init(name: String) { self.name = name }
}

struct Board {
    var layers: [Layer]
}

var board = Board(layers: [Layer(name: "Background")])
let snapshot = board
board.layers[0].name = "Sky"
print("snapshot sees:", snapshot.layers[0].name)
