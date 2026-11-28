// Reference solution: Commands that undo themselves. Applying a command returns its inverse, so nothing
// needs a snapshot of the whole list. History keeps (name, inverse) pairs on two stacks: undoing applies
// the inverse, which hands back the command that redoes it, under the same name, just as UndoManager's
// undo handlers register their own redo. A batch reverses its inverses so they unwind in the right order.
import Foundation

public enum PackingListUndo {
    public struct Checklist: Equatable, Sendable {
        public var items: [String]

        public init(_ items: [String] = []) {
            self.items = items
        }
    }

    public protocol Command {
        var actionName: String { get }
        func apply(to list: inout Checklist) -> (any Command)?
    }

    public struct Add: Command {
        public let item: String
        public var actionName: String { "Add \(item)" }

        public init(_ item: String) {
            self.item = item
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            list.items.append(item)
            return Remove(at: list.items.count - 1)
        }
    }

    public struct Insert: Command {
        public let item: String
        public let index: Int
        public var actionName: String { "Insert \(item)" }

        public init(_ item: String, at index: Int) {
            self.item = item
            self.index = index
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            guard (0...list.items.count).contains(index) else { return nil }
            list.items.insert(item, at: index)
            return Remove(at: index)
        }
    }

    public struct Remove: Command {
        public let index: Int
        public var actionName: String { "Remove" }

        public init(at index: Int) {
            self.index = index
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            guard list.items.indices.contains(index) else { return nil }
            let removed = list.items.remove(at: index)
            return Insert(removed, at: index)
        }
    }

    public struct Rename: Command {
        public let index: Int
        public let newName: String
        public var actionName: String { "Rename" }

        public init(at index: Int, to newName: String) {
            self.index = index
            self.newName = newName
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            guard list.items.indices.contains(index), list.items[index] != newName else { return nil }
            let oldName = list.items[index]
            list.items[index] = newName
            return Rename(at: index, to: oldName)
        }
    }

    public struct Batch: Command {
        public let actionName: String
        public let commands: [any Command]

        public init(_ actionName: String, _ commands: [any Command]) {
            self.actionName = actionName
            self.commands = commands
        }

        public func apply(to list: inout Checklist) -> (any Command)? {
            let inverses = commands.compactMap { $0.apply(to: &list) }
            return inverses.isEmpty ? nil : Batch(actionName, inverses.reversed())
        }
    }

    public struct History {
        private struct Step {
            let name: String
            let reverse: any Command
        }

        public private(set) var list: Checklist
        private var undoStack: [Step] = []
        private var redoStack: [Step] = []

        public init(_ list: Checklist = Checklist()) {
            self.list = list
        }

        public var canUndo: Bool { !undoStack.isEmpty }
        public var canRedo: Bool { !redoStack.isEmpty }
        public var undoActionName: String? { undoStack.last?.name }
        public var redoActionName: String? { redoStack.last?.name }

        public mutating func perform(_ command: any Command) {
            guard let inverse = command.apply(to: &list) else { return }
            undoStack.append(Step(name: command.actionName, reverse: inverse))
            redoStack.removeAll()
        }

        public mutating func undo() {
            guard let step = undoStack.popLast(), let redo = step.reverse.apply(to: &list) else { return }
            redoStack.append(Step(name: step.name, reverse: redo))
        }

        public mutating func redo() {
            guard let step = redoStack.popLast(), let undo = step.reverse.apply(to: &list) else { return }
            undoStack.append(Step(name: step.name, reverse: undo))
        }
    }
}
