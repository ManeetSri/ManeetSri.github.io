// Problem: A bank of mergeable heaps (M39 · Binomial and Fibonacci heaps)

public enum MeldableHeapBank {
    /// Min-heaps numbered 0..<count that can be melded cheaply: `meld(s, into: t)` moves every value of
    /// heap s into heap t and leaves s empty. Aim for O(log n) or better per operation (amortised is
    /// fine), for example with pairing heaps whose nodes live in arrays.
    public struct HeapBank {
        // Write your solution here, then run:
        // swift test --filter MeldableHeapBankTests
        // Add the private storage you need: node arrays shared by every heap work well.

        /// Creates `count` empty heaps, numbered 0..<count.
        public init(count: Int) {
        }

        /// How many values heap `heap` holds.
        public func size(of heap: Int) -> Int {
            return 0
        }

        /// The smallest value in heap `heap`, or nil if it's empty.
        public func min(of heap: Int) -> Int? {
            return nil
        }

        /// Adds `newValue` to heap `heap`.
        public mutating func push(_ newValue: Int, onto heap: Int) {
        }

        /// Removes and returns the smallest value of heap `heap`, or nil if it's empty.
        public mutating func popMin(from heap: Int) -> Int? {
            return nil
        }

        /// Moves every value of heap `source` into heap `target`, leaving `source` empty. Melding a heap
        /// into itself does nothing.
        public mutating func meld(_ source: Int, into target: Int) {
        }
    }
}
