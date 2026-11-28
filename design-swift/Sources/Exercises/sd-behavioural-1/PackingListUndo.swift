// Kata: Commands that undo themselves (D12 · Command and UndoManager)
import Foundation

public enum PackingListUndo {
    /// The document being edited: a packing list
    public struct Checklist: Equatable, Sendable {
        public var items: [String]

        public init(_ items: [String] = []) {
            self.items = items
        }
    }

    /// One change to a checklist, kept as a value so it can be applied, stored and reversed
    public protocol Command {
        /// What an Undo menu calls the change, such as "Add Passport"
        var actionName: String { get }

        /// Makes the change and returns the command that reverses it, or nil when nothing changed
        func apply(to list: inout Checklist) -> (any Command)?
    }

    /// Adds `item` at the end. Its name is "Add <item>".
    public struct Add: Command {
        public let item: String
        public var actionName: String { "Add \(item)" }

        public init(_ item: String) {
            self.item = item
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            // Write your solution here, then run:
            // swift test --filter PackingListUndoTests
            nil
        }
    }

    /// Inserts `item` at `index`, which may be anything from 0 to the item count. Its name is "Insert <item>".
    public struct Insert: Command {
        public let item: String
        public let index: Int
        public var actionName: String { "Insert \(item)" }

        public init(_ item: String, at index: Int) {
            self.item = item
            self.index = index
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            nil
        }
    }

    /// Removes the item at `index`. Its name is "Remove".
    public struct Remove: Command {
        public let index: Int
        public var actionName: String { "Remove" }

        public init(at index: Int) {
            self.index = index
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            nil
        }
    }

    /// Renames the item at `index`. Its name is "Rename".
    public struct Rename: Command {
        public let index: Int
        public let newName: String
        public var actionName: String { "Rename" }

        public init(at index: Int, to newName: String) {
            self.index = index
            self.newName = newName
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            nil
        }
    }

    /// Several commands that undo and redo as one step, such as "Remove Packed"
    public struct Batch: Command {
        public let actionName: String
        public let commands: [any Command]

        public init(_ actionName: String, _ commands: [any Command]) {
            self.actionName = actionName
            self.commands = commands
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            nil
        }
    }

    /// Performs commands on a checklist and keeps what it needs to undo and redo them
    public struct History {
        public private(set) var list: Checklist

        public init(_ list: Checklist = Checklist()) {
            self.list = list
        }

        public var canUndo: Bool { false }
        public var canRedo: Bool { false }

        /// The name of the change `undo()` would reverse, for a menu item such as "Undo Add Passport"
        public var undoActionName: String? { nil }

        /// The name of the change `redo()` would make again
        public var redoActionName: String? { nil }

        /// Applies `command`. A command that changes nothing isn't recorded. A new change clears redo.
        public mutating func perform(_ command: any Command) {}

        /// Reverses the latest change, if there is one
        public mutating func undo() {}

        /// Makes the latest undone change again, if there is one
        public mutating func redo() {}
    }
}
