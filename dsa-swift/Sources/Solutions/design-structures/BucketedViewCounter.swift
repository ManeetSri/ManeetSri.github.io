// Reference solution: Bucketed view counter. One (time, views) bucket per second that had views,
// oldest first, in a deque, plus a running total. Old buckets leave from the front as time moves
// on, so `record` and `count` are amortised O(1), whatever the number of views, and memory is
// O(window) buckets at most.

import DSAKit

public enum BucketedViewCounter {
    public struct Counter {
        private let window: Int
        private var buckets = Deque<(time: Int, views: Int)>()
        private var total = 0

        public init(window: Int) {
            precondition(window > 0, "The window must be at least one second")
            self.window = window
        }

        public mutating func record(_ views: Int = 1, at time: Int) {
            expire(at: time)
            if let last = buckets.last, last.time == time {
                buckets[buckets.count - 1].views += views     // same second: grow its bucket
            } else {
                buckets.append((time, views))
            }
            total += views
        }

        public mutating func count(at time: Int) -> Int {
            expire(at: time)
            return total
        }

        /// Drops every bucket at or before `time - window`: it can never count again.
        private mutating func expire(at time: Int) {
            while let oldest = buckets.first, oldest.time <= time - window {
                total -= oldest.views
                buckets.popFirst()
            }
        }
    }
}
