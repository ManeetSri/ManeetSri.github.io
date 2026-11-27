// Problem: A copy-on-write stack (M11 · Writing your own copy-on-write)

public enum CopyOnWriteStack {
    /// Holds a stack's elements. Copies of a Stack share one Storage until one of them changes.
    final class Storage {
        var items: [Int]

        init(items: [Int]) {
            self.items = items
        }
    }

    /// A last-in, first-out stack of Ints with value semantics, built on shared Storage.
    public struct Stack {
        private var storage: Storage

        /// An empty stack.
        public init() {
            storage = Storage(items: [])
        }

        /// A stack holding `elements`, with the last element on top.
        public init(_ elements: [Int]) {
            storage = Storage(items: elements)
        }

        /// An identity for the storage this stack uses right now. It doesn't keep the storage alive.
        public var storageID: ObjectIdentifier {
            ObjectIdentifier(storage)
        }

        /// The number of elements.
        public var count: Int {
            // Write your solution here, then run:
            // swift test --filter CopyOnWriteStackTests
            return 0
        }

        /// True when the stack has no elements.
        public var isEmpty: Bool {
            return true
        }

        /// The top element, or nil if the stack is empty.
        public var top: Int? {
            return nil
        }

        /// Every element from bottom to top.
        public var elements: [Int] {
            return []
        }

        /// Puts `value` on top. Must not change any other copy of this stack.
        public mutating func push(_ value: Int) {
        }

        /// Removes and returns the top element, or returns nil if the stack is empty. Must not change any
        /// other copy of this stack.
        public mutating func pop() -> Int? {
            return nil
        }

        /// Removes every element. Must not change any other copy of this stack.
        public mutating func removeAll() {
        }

        /// True when this stack and `other` use the same storage object.
        public func isSharingStorage(with other: Stack) -> Bool {
            return false
        }
    }
}
