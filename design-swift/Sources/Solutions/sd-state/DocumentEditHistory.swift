// Reference solution: Undo and redo history. Two stacks of snapshots: the undo stack holds the versions
// before each change, the redo stack the versions undo stepped back from. Snapshots are cheap because
// Document is a value type: Swift's collections share storage until one copy is changed.
import Foundation

public enum DocumentEditHistory {
    public struct History<Document: Equatable & Sendable>: Sendable {
        private struct Entry: Sendable {
            let document: Document
            let actionName: String
        }

        public private(set) var current: Document
        public let limit: Int

        private var undoStack: [Entry] = []
        private var redoStack: [Entry] = []
        /// The name of the last change if it may absorb the next coalescing one, else nil
        private var openGroup: String?

        public init(_ document: Document, limit: Int = 100) {
            current = document
            self.limit = max(0, limit)
        }

        public var canUndo: Bool { !undoStack.isEmpty }
        public var canRedo: Bool { !redoStack.isEmpty }
        public var undoActionName: String? { undoStack.last?.actionName }
        public var redoActionName: String? { redoStack.last?.actionName }

        public mutating func apply(_ document: Document, actionName: String, coalescing: Bool = false) {
            guard document != current else { return }
            redoStack.removeAll()
            if coalescing, openGroup == actionName, !undoStack.isEmpty {
                // The entry already holds the version before the first change in the group
                current = document
                return
            }
            undoStack.append(Entry(document: current, actionName: actionName))
            if undoStack.count > limit {
                undoStack.removeFirst(undoStack.count - limit)
            }
            current = document
            openGroup = coalescing ? actionName : nil
        }

        public mutating func undo() {
            guard let entry = undoStack.popLast() else { return }
            redoStack.append(Entry(document: current, actionName: entry.actionName))
            current = entry.document
            openGroup = nil
        }

        public mutating func redo() {
            guard let entry = redoStack.popLast() else { return }
            undoStack.append(Entry(document: current, actionName: entry.actionName))
            current = entry.document
            openGroup = nil
        }
    }
}
