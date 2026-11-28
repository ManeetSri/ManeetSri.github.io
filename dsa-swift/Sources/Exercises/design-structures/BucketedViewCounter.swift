// Problem: Bucketed view counter (M72 · Hit counter and time-based key-value store)

public enum BucketedViewCounter {
    /// Counts the views of a page during the last `window` seconds. Times are whole seconds and
    /// never go backwards from one call to the next.
    public struct Counter {
        // Write your solution here, then run:
        // swift test --filter BucketedViewCounterTests
        // Add whatever private storage you need. A single call can record millions of views.

        /// Creates a counter for a window of `window` seconds (at least 1).
        public init(window: Int) {
        }

        /// Records `views` views (at least 1) at second `time`.
        public mutating func record(_ views: Int = 1, at time: Int) {
        }

        /// The total views recorded from `time - window + 1` to `time`, both included.
        public mutating func count(at time: Int) -> Int {
            return 0
        }
    }
}
