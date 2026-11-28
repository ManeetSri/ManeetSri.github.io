// Problem: A priority queue with changeable keys (M39 · d-ary heaps and indexed priority queues)

public enum DecreaseKeyQueue {
    /// An indexed min-priority queue of ids 0..<capacity. `push` inserts an id or changes its key (up or
    /// down); the smallest key comes out first, and equal keys go by smaller id. O(1) `contains`,
    /// `key(of:)` and `peek()`; O(log n) `push`, `remove` and `popMin()`.
    public struct IndexedQueue {
        // Write your solution here, then run:
        // swift test --filter DecreaseKeyQueueTests
        // Add the private storage you need: the heap of ids, the keys and a position for every id.

        /// Creates an empty queue for ids 0..<capacity.
        public init(capacity: Int) {
        }

        /// How many ids are queued.
        public var count: Int {
            return 0
        }

        /// True when no ids are queued.
        public var isEmpty: Bool {
            return true
        }

        /// True if `id` is queued. O(1).
        public func contains(_ id: Int) -> Bool {
            return false
        }

        /// The key of `id`, or nil if it isn't queued. O(1).
        public func key(of id: Int) -> Int? {
            return nil
        }

        /// The queued id with the smallest key (the smaller id between equal keys), or nil. O(1).
        public func peek() -> (id: Int, key: Int)? {
            return nil
        }

        /// Queues `id` with `key`, or changes its key if it's already queued. O(log n).
        public mutating func push(_ id: Int, key: Int) {
        }

        /// Removes `id`, returning true if it was queued. O(log n).
        @discardableResult
        public mutating func remove(_ id: Int) -> Bool {
            return false
        }

        /// Removes and returns the queued id with the smallest key, or nil when empty. O(log n).
        public mutating func popMin() -> (id: Int, key: Int)? {
            return nil
        }
    }
}
