// Reference solution: Undo and redo for a text buffer. Every edit is a command that knows how to
// apply itself and what its inverse is: an insert is undone by deleting the same text, and a
// delete stores the text it removed so it can be put back. Two stacks hold the commands. A new
// edit empties the redo stack. The undo stack is a deque so the oldest command can fall off the
// front when the limit is reached. Undo and redo cost what the edit itself costs, never a copy of
// the whole text.

import DSAKit

public enum UndoRedoEditor {
    public struct Editor {
        private enum Edit {
            case insert(text: [Character], offset: Int)
            case delete(text: [Character], offset: Int)

            var inverse: Edit {
                switch self {
                case let .insert(text, offset): return .delete(text: text, offset: offset)
                case let .delete(text, offset): return .insert(text: text, offset: offset)
                }
            }
        }

        private var buffer: [Character] = []
        private var undoStack = Deque<Edit>()          // newest at the back
        private var redoStack: [Edit] = []
        private let undoLimit: Int

        public init(undoLimit: Int = .max) {
            precondition(undoLimit >= 0, "The undo limit can't be negative")
            self.undoLimit = undoLimit
        }

        public var text: String {
            String(buffer)
        }

        public var canUndo: Bool {
            !undoStack.isEmpty
        }

        public var canRedo: Bool {
            !redoStack.isEmpty
        }

        public mutating func insert(_ text: String, at offset: Int) {
            precondition(offset >= 0 && offset <= buffer.count, "Offset \(offset) is outside the text")
            guard !text.isEmpty else { return }
            record(.insert(text: Array(text), offset: offset))
        }

        public mutating func delete(from offset: Int, count: Int) {
            precondition(offset >= 0 && count >= 0 && offset + count <= buffer.count, "The range is outside the text")
            guard count > 0 else { return }
            record(.delete(text: Array(buffer[offset..<offset + count]), offset: offset))
        }

        @discardableResult
        public mutating func undo() -> Bool {
            guard let edit = undoStack.popLast() else { return false }
            apply(edit.inverse)
            redoStack.append(edit)
            return true
        }

        @discardableResult
        public mutating func redo() -> Bool {
            guard let edit = redoStack.popLast() else { return false }
            apply(edit)
            undoStack.append(edit)                     // room is guaranteed: undo made it
            return true
        }

        private mutating func record(_ edit: Edit) {
            apply(edit)
            redoStack.removeAll()                      // the undone future can't be reached any more
            undoStack.append(edit)
            if undoStack.count > undoLimit {
                undoStack.popFirst()                   // forget the oldest step
            }
        }

        private mutating func apply(_ edit: Edit) {
            switch edit {
            case let .insert(text, offset):
                buffer.insert(contentsOf: text, at: offset)
            case let .delete(text, offset):
                buffer.removeSubrange(offset..<offset + text.count)
            }
        }
    }
}
