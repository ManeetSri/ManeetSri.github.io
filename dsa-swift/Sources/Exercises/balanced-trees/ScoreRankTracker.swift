// Problem: Score rank tracker (M38 · Treaps: split and merge)

public enum ScoreRankTracker {
    /// Scores arrive one at a time, repeats allowed, and at any moment you can ask how many recorded
    /// scores are at most x, or which score is the kth smallest.
    public final class Tracker {
        // Write your solution here, then run:
        // swift test --filter ScoreRankTrackerTests
        // Add whatever private storage you need.

        public init() {}

        /// Records one more score. O(log n).
        public func record(_ score: Int) {
        }

        /// How many recorded scores are less than or equal to `score`, counting repeats. O(log n).
        public func countAtMost(_ score: Int) -> Int {
            return 0
        }

        /// The kth smallest recorded score, counting repeats, with k = 1 for the smallest; nil if k is
        /// below 1 or more than the number of scores. O(log n).
        public func kthSmallest(_ k: Int) -> Int? {
            return nil
        }

        /// How many scores have been recorded.
        public var count: Int {
            return 0
        }
    }
}
