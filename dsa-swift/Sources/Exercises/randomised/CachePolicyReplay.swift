// Problem: Replay a cache trace (M67 · Cache policies: LRU, LFU and FIFO)

import DSAKit

public enum CachePolicyReplay {
    /// Which id a full cache evicts when a new one arrives.
    public enum Policy: Sendable, CaseIterable {
        /// The id that entered the cache longest ago. Hits change nothing.
        case fifo
        /// The id whose most recent request is the oldest.
        case lru
        /// The id with the fewest requests since it entered the cache; ties go to the least recently
        /// requested. An evicted id's count is forgotten.
        case lfu
    }

    /// Replays `trace` through an initially empty cache of at most `capacity` ids and returns the
    /// number of hits. Aim for O(1) or O(log n) per request.
    public static func hits(trace: [Int], capacity: Int, policy: Policy) -> Int {
        // Write your solution here, then run:
        // swift test --filter CachePolicyReplayTests
        // DSAKit's Heap is imported, if you want it.
        return 0
    }
}
