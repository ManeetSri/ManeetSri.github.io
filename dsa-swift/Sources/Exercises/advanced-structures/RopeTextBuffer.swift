// Problem: Rope text buffer (M64 · Ropes for text editors)

public enum RopeTextBuffer {
    /// An editable text buffer indexed by Character, with undo. Every call to `insert` or `delete` is one
    /// edit, even if it changes nothing. A copy of a buffer is independent of the original, undo history
    /// included.
    ///
    /// Aim for O(log n) edits and lookups and O(1) undo: a balanced rope of immutable nodes makes that
    /// natural, but any design that passes the tests is fine.
    public struct Buffer {
        public init(_ text: String = "") {
            // Write your solution here, then run:
            // swift test --filter RopeTextBufferTests
        }

        /// The number of characters.
        public var count: Int {
            return 0
        }

        /// The whole text.
        public var text: String {
            return ""
        }

        /// The character at `index`, which is in 0..<count.
        public func character(at index: Int) -> Character {
            return " "
        }

        /// `count` characters starting at `start`. The range lies within the text.
        public func slice(from start: Int, count: Int) -> String {
            return ""
        }

        /// Inserts `text` so that its first character ends up at `index` (0...count).
        public mutating func insert(_ text: String, at index: Int) {
        }

        /// Deletes `count` characters starting at `start`. The range lies within the text.
        public mutating func delete(from start: Int, count: Int) {
        }

        /// Restores the text as it was before the most recent edit that hasn't been undone. Returns false,
        /// and changes nothing, if there's nothing to undo.
        @discardableResult
        public mutating func undo() -> Bool {
            return false
        }
    }
}
