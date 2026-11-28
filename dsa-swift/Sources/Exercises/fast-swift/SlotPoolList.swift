// Problem: A linked list in a slot pool (M68 · Index-based nodes vs class nodes)

public enum SlotPoolList {
    /// A doubly linked list of Ints whose nodes live in an array of structs, linked by Int indices instead
    /// of class references. A node's slot number in that array is its handle.
    ///
    /// When a node is removed, its slot goes on a free list. A new node always takes the most recently
    /// freed slot; only when no slot is free does it take a new one, numbered `slotCount`. Aim for O(1)
    /// for every operation except `values` and `valuesBackward`.
    public struct List {
        public init() {
            // Write your solution here, then run:
            // swift test --filter SlotPoolListTests
        }

        /// The number of values in the list.
        public var count: Int {
            return 0
        }

        /// The number of slots created so far, in use or free.
        public var slotCount: Int {
            return 0
        }

        /// Every value, from front to back.
        public var values: [Int] {
            return []
        }

        /// Every value, from back to front, found by following the backward links.
        public var valuesBackward: [Int] {
            return []
        }

        /// The value stored in the node with this handle. The handle is always in use.
        public func value(at handle: Int) -> Int {
            return 0
        }

        /// Adds `value` at the front and returns its handle.
        @discardableResult
        public mutating func pushFront(_ value: Int) -> Int {
            return 0
        }

        /// Adds `value` at the back and returns its handle.
        @discardableResult
        public mutating func pushBack(_ value: Int) -> Int {
            return 0
        }

        /// Adds `value` straight after the node with this handle and returns the new node's handle.
        @discardableResult
        public mutating func insert(_ value: Int, after handle: Int) -> Int {
            return 0
        }

        /// Removes the node with this handle, frees its slot, and returns its value. The handle is always
        /// in use.
        @discardableResult
        public mutating func remove(_ handle: Int) -> Int {
            return 0
        }
    }
}
