// Problem: Kth cheapest trade in a range (M60 · Persistent segment trees)

public enum PersistentRangeKth {
    /// Answers "the kth smallest of prices[left...right]" in O(log n) after an O(n log n) set-up.
    public struct Finder {
        // Write your solution here, then run:
        // swift test --filter PersistentRangeKthTests
        // Add whatever private storage you need: parallel node arrays, one root per prefix, the
        // sorted distinct prices.

        /// Prepares the finder for `prices` (at least one price).
        public init(_ prices: [Int]) {}

        /// The kth smallest (k from 1) of prices[left...right], counting equal prices separately.
        public func kthSmallest(_ k: Int, from left: Int, through right: Int) -> Int {
            return 0
        }
    }
}
