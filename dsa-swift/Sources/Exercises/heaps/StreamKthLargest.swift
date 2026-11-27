// Problem: Kth highest score in a stream (M39 · Top K, kth largest and K closest)

import DSAKit

public enum StreamKthLargest {
    /// Watches scores arrive one at a time and reports the kth highest so far (counting duplicates):
    /// the score a newcomer has to beat to make a top-k leaderboard.
    public struct KthLargestTracker {
        // Write your solution here, then run:
        // swift test --filter StreamKthLargestTests
        // Add the private storage you need. DSAKit's Heap is imported, if you want it.

        /// Creates a tracker for the kth highest score (k ≥ 1).
        public init(k: Int) {
        }

        /// Records `score` and returns the kth highest score recorded so far, or nil while fewer
        /// than k scores have arrived.
        public mutating func add(_ score: Int) -> Int? {
            return nil
        }
    }
}
