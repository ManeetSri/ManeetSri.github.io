// Generated from src/dsa/content/lessons/concurrent-structures/cc-mutex-atomics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Synchronization

/// Request statistics with no lock at all: each figure is one atomic Int
final class RequestStats: Sendable {
    private let requests = Atomic<Int>(0)
    private let slowest = Atomic<Int>(0)

    func record(milliseconds: Int) {
        requests.add(1, ordering: .relaxed)

        // A lock-free maximum: try to swap in the new value, and retry if another task got there first
        var current = slowest.load(ordering: .relaxed)
        while milliseconds > current {
            let (exchanged, original) = slowest.compareExchange(
                expected: current, desired: milliseconds, ordering: .relaxed)
            if exchanged { break }
            current = original          // someone else changed it: compare against their value
        }
    }

    var summary: (requests: Int, slowest: Int) {
        (requests.load(ordering: .relaxed), slowest.load(ordering: .relaxed))
    }
}

let stats = RequestStats()
await withTaskGroup(of: Void.self) { group in
    for request in 0..<1_000 {
        group.addTask {
            stats.record(milliseconds: (request * 37) % 500)    // made-up durations, from 0 to 499
        }
    }
}
let summary = stats.summary
print(summary.requests, summary.slowest)
