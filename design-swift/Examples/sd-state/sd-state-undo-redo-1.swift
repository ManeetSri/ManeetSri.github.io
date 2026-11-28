// Generated from src/dsa/design/content/lessons/sd-state/sd-state-undo-redo.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// A drawing, as a value: a snapshot is a copy of it
struct Drawing: Equatable {
    var shapes: [String] = []
}

@MainActor
final class DrawingModel {
    private(set) var drawing = Drawing()
    let undoManager = UndoManager()

    /// Every change goes through here, so every change can be undone
    func change(_ actionName: String, _ edit: (inout Drawing) -> Void) {
        let before = drawing
        edit(&drawing)
        guard drawing != before else { return }
        registerRestore(of: before, actionName: actionName)
    }

    private func registerRestore(of snapshot: Drawing, actionName: String) {
        undoManager.registerUndo(withTarget: self) { model in
            let current = model.drawing
            model.drawing = snapshot
            // Registering while undoing records the redo, and the other way round
            model.registerRestore(of: current, actionName: actionName)
        }
        undoManager.setActionName(actionName)
    }
}

let model = DrawingModel()
// In an app, everything registered while handling one event is one group. A script has no
// events, so it opens and closes its groups itself.
model.undoManager.groupsByEvent = false

model.undoManager.beginUndoGrouping()
model.change("Add Circle") { $0.shapes.append("circle") }
model.undoManager.endUndoGrouping()

model.undoManager.beginUndoGrouping()
model.change("Add Shapes") { $0.shapes.append("square") }
model.change("Add Shapes") { $0.shapes.append("star") }
model.undoManager.endUndoGrouping()

print(model.drawing.shapes, "· undo:", model.undoManager.undoActionName)
model.undoManager.undo()
print(model.drawing.shapes, "· redo:", model.undoManager.redoActionName)
model.undoManager.undo()
print(model.drawing.shapes, "·", model.undoManager.canUndo ? "can undo" : "nothing to undo")
model.undoManager.redo()
print(model.drawing.shapes, "· undo:", model.undoManager.undoActionName)
