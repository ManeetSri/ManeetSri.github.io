// Problem: Signal spread time (M44 · Dijkstra's algorithm)

import DSAKit

public enum SignalSpreadTime {
    /// Servers are numbered 0..<n, and each link [from, to, delay] carries a signal one way in `delay`
    /// milliseconds. Returns how long it takes a signal sent from `source` to reach every server, or -1
    /// if some server never receives it.
    public static func spreadTime(n: Int, links: [[Int]], source: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter SignalSpreadTimeTests
        // DSAKit's Heap is imported, if you want it.
        return 0
    }
}
