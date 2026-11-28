// Problem: Undo and redo for a text buffer (M72 · Undo and redo manager)

public enum UndoRedoEditor {
    /// A text buffer with undo and redo. Offsets count Characters from the start of the text.
    public struct Editor {
        // Write your solution here, then run:
        // swift test --filter UndoRedoEditorTests
        // Add whatever private storage you need. Don't keep a copy of the whole text per edit.

        /// Creates an empty buffer that remembers at most `undoLimit` edits to undo (0 or more).
        public init(undoLimit: Int = .max) {
        }

        /// The current text.
        public var text: String {
            return ""
        }

        /// True if there's an edit to undo.
        public var canUndo: Bool {
            return false
        }

        /// True if there's an undone edit to redo.
        public var canRedo: Bool {
            return false
        }

        /// Inserts `text` so that it starts at `offset` (0 to the text's length). Inserting an empty
        /// string changes nothing and isn't an edit.
        public mutating func insert(_ text: String, at offset: Int) {
        }

        /// Deletes `count` characters starting at `offset`. Deleting 0 characters changes nothing and
        /// isn't an edit.
        public mutating func delete(from offset: Int, count: Int) {
        }

        /// Reverts the most recent edit that hasn't been undone. Returns false if there's none.
        @discardableResult
        public mutating func undo() -> Bool {
            return false
        }

        /// Re-applies the most recently undone edit. Returns false if there's none.
        @discardableResult
        public mutating func redo() -> Bool {
            return false
        }
    }
}
