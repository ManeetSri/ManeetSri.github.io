// Reference solution: Replay a cache trace. Every policy evicts the cached id with the smallest
// priority: (0, time entered) for FIFO, (0, latest request) for LRU and (requests since entering,
// latest request) for LFU. A dictionary holds each cached id's current priority, and a min-heap holds
// (priority, id) entries with lazy deletion: a changed priority pushes a new entry, and eviction pops
// until it finds an entry that matches its id's current priority. Times are unique, so priorities
// never tie. O(n log n) time, O(n) space.

import DSAKit

public enum CachePolicyReplay {
    public enum Policy: Sendable, CaseIterable {
        case fifo
        case lru
        case lfu
    }

    public static func hits(trace: [Int], capacity: Int, policy: Policy) -> Int {
        typealias Priority = (first: Int, second: Int)
        var current: [Int: Priority] = [:]                 // cached id -> its priority now
        var uses: [Int: Int] = [:]                         // cached id -> requests since it entered
        var heap = Heap<(priority: Priority, id: Int)>(areInIncreasingOrder: { $0.priority < $1.priority })
        var hitCount = 0

        for (time, id) in trace.enumerated() {
            if current[id] != nil {
                hitCount += 1
                uses[id]! += 1
                if policy == .fifo { continue }            // a FIFO hit changes nothing
            } else {
                if current.count == capacity {             // evict the smallest live priority
                    while let entry = heap.pop() {
                        if let live = current[entry.id], live == entry.priority {
                            current[entry.id] = nil
                            uses[entry.id] = nil
                            break
                        }
                    }
                }
                uses[id] = 1
            }
            let priority: Priority = policy == .lfu ? (uses[id]!, time) : (0, time)
            current[id] = priority
            heap.insert((priority, id))
        }
        return hitCount
    }
}
