// Generated from src/dsa/content/lessons/concurrent-structures/cc-sendable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

/// Thread-safe because every access to `counts` holds the lock. The compiler can't verify that,
/// so the conformance is @unchecked: a promise you make.
final class HitCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [String: Int] = [:]

    func record(_ page: String) {
        lock.lock()
        defer { lock.unlock() }
        counts[page, default: 0] += 1
    }

    func count(for page: String) -> Int {
        lock.lock()
        defer { lock.unlock() }
        return counts[page, default: 0]
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
