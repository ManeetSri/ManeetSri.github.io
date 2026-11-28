// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-command.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

@MainActor
final class Note {
    let undoManager = UndoManager()
    private(set) var title: String
    private(set) var tags: [String] = []

    init(title: String) {
        self.title = title
        // An app's run loop closes an undo group after each event; a script has none, so group by hand
        undoManager.groupsByEvent = false
    }

    func rename(to newTitle: String) {
        let oldTitle = title
        // Register the inverse. When undo runs it, rename registers *its* inverse, which becomes redo.
        undoManager.registerUndo(withTarget: self) { note in
            note.rename(to: oldTitle)
        }
        title = newTitle
    }

    func addTag(_ tag: String) {
        undoManager.registerUndo(withTarget: self) { note in
            note.removeTag(tag)
        }
        tags.append(tag)
    }

    func removeTag(_ tag: String) {
        guard let index = tags.firstIndex(of: tag) else { return }
        undoManager.registerUndo(withTarget: self) { note in
            note.addTag(tag)
        }
        tags.remove(at: index)
    }

    /// One user action: everything inside undoes as one step, under one name
    func edit(_ name: String, _ change: (Note) -> Void) {
        undoManager.beginUndoGrouping()
        change(self)
        undoManager.setActionName(name)
        undoManager.endUndoGrouping()
    }

    func show(_ label: String) {
        let undo = undoManager.canUndo ? undoManager.undoActionName : "–"
        let redo = undoManager.canRedo ? undoManager.redoActionName : "–"
        print("\(label) → \(title) \(tags) | Undo: \(undo) | Redo: \(redo)")
    }
}

let note = Note(title: "Draft")
note.edit("Rename") { $0.rename(to: "Shopping") }
note.edit("Add Tags") { note in
    note.addTag("home")
    note.addTag("weekly")
}
note.show("edited")
note.undoManager.undo()
note.show("undo")
note.undoManager.undo()
note.show("undo")
note.undoManager.redo()
note.show("redo")
note.edit("Add Tag") { $0.addTag("urgent") }
note.show("edited")
