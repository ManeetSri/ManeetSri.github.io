// Generated from src/dsa/content/lessons/concurrent-structures/cc-mutex-atomics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Synchronization

/// The hit counter from the Sendable lesson, rebuilt on Mutex: checked Sendable, no @unchecked
final class HitCounter: Sendable {
    private let counts = Mutex<[String: Int]>([:])

    func record(_ page: String) {
        counts.withLock { counts in
            counts[page, default: 0] += 1
        }
    }

    func count(for page: String) -> Int {
        counts.withLock { $0[page, default: 0] }
    }

    /// Several reads in one lock, so they're consistent with each other
    func topPage() -> (page: String, hits: Int)? {
        counts.withLock { counts in
            counts.max { ($0.value, $1.key) < ($1.value, $0.key) }.map { ($0.key, $0.value) }
        }
    }
}

let hits = HitCounter()
await withTaskGroup(of: Void.self) { group in
    for visitor in 0..<300 {
        group.addTask {
            hits.record(visitor.isMultiple(of: 3) ? "home" : "search")
        }
    }
}
print(hits.count(for: "home"), hits.count(for: "search"), hits.count(for: "cart"))
if let top = hits.topPage() {
    print(top.page, top.hits)
}
