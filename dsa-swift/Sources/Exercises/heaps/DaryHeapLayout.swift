// Problem: A heap with d children per node (M39 · d-ary heaps and indexed priority queues)

public enum DaryHeapLayout {
    /// A min-heap where every node has up to `arity` children, stored level by level in `storage`:
    /// the children of i are arity * i + 1 through arity * i + arity, and the parent is (i - 1) / arity.
    /// Follow the statement's sift rules exactly: the tests check `storage` after every operation.
    public struct DaryMinHeap {
        // Write your solution here, then run:
        // swift test --filter DaryHeapLayoutTests

        /// How many children each node may have.
        public let arity: Int

        /// The heap, level by level, with the smallest value at index 0.
        public private(set) var storage: [Int] = []

        /// Creates an empty heap.
        public init(arity: Int) {
            self.arity = arity
        }

        /// Creates a heap holding `items` with bottom-up heapify, in O(n).
        public init(arity: Int, items: [Int]) {
            self.arity = arity
        }

        /// How many values the heap holds.
        public var count: Int {
            return 0
        }

        /// The smallest value, or nil when empty. O(1).
        public func peek() -> Int? {
            return nil
        }

        /// Adds `value` and sifts it up. O(log_d n).
        public mutating func push(_ value: Int) {
        }

        /// Removes and returns the smallest value, or nil when empty. O(d log_d n).
        public mutating func pop() -> Int? {
            return nil
        }
    }
}
