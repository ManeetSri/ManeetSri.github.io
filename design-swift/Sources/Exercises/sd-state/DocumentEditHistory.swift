// Kata: Undo and redo history (D19 · Undo and redo with UndoManager)
import Foundation

public enum DocumentEditHistory {
    /// Every version of a document the user can step back and forward through
    public struct History<Document: Equatable & Sendable>: Sendable {
        /// The document as the user sees it now
        public private(set) var current: Document
        /// The most changes that can be undone; older ones are forgotten
        public let limit: Int

        public init(_ document: Document, limit: Int = 100) {
            current = document
            self.limit = max(0, limit)
        }

        public var canUndo: Bool { false }
        public var canRedo: Bool { false }

        /// The name of the change `undo()` would revert, for a menu item such as "Undo Typing"
        public var undoActionName: String? { nil }
        /// The name of the change `redo()` would reapply
        public var redoActionName: String? { nil }

        /// Makes `document` the current version. A change equal to the current document isn't recorded.
        /// With `coalescing`, it joins the previous change when that one had the same name and was also
        /// coalescing, and nothing has been undone or redone since: one undo then reverts them all.
        public mutating func apply(_ document: Document, actionName: String, coalescing: Bool = false) {
            // Write your solution here, then run:
            // swift test --filter DocumentEditHistoryTests
        }

        /// Steps back one change, if there is one
        public mutating func undo() {}

        /// Steps forward one undone change, if there is one
        public mutating func redo() {}
    }
}
