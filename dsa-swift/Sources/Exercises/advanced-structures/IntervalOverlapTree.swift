// Problem: Interval overlap tree (M64 · Interval trees)

public enum IntervalOverlapTree {
    /// A changing set of closed intervals [start, end], each with a unique id.
    ///
    /// Aim for O(log n) insert and remove, and queries that skip the parts of the tree that can't
    /// overlap: an augmented, balanced search tree.
    public final class Tree {
        public init() {
            // Write your solution here, then run:
            // swift test --filter IntervalOverlapTreeTests
        }

        /// The number of intervals.
        public var count: Int {
            return 0
        }

        /// Adds [start, end] (start ≤ end) under `id`. Returns false, and changes nothing, if `id` is
        /// already in use.
        @discardableResult
        public func insert(start: Int, end: Int, id: Int) -> Bool {
            return false
        }

        /// Removes the interval with `id`. Returns false if there isn't one.
        @discardableResult
        public func remove(id: Int) -> Bool {
            return false
        }

        /// The ids of every interval sharing at least one point with [start, end], in increasing order.
        public func overlapping(start: Int, end: Int) -> [Int] {
            return []
        }

        /// The ids of every interval containing `point`, in increasing order.
        public func containing(_ point: Int) -> [Int] {
            return []
        }
    }
}
