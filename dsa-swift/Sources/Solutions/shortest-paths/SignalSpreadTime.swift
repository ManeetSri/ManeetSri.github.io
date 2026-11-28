// Reference solution: Signal spread time. The signal reaches each server along its fastest route,
// which is its shortest distance from the source, and everyone has it once the slowest server does:
// the answer is the largest shortest distance. Delays are non-negative, so Dijkstra with a min-heap of
// (time, server) and lazy deletion. Servers come out of the heap in arrival order, so the last one
// settled is the answer, and counting settled servers detects anyone unreachable.
// O((n + m) log n) time, O(n + m) space.

import DSAKit

public enum SignalSpreadTime {
    public static func spreadTime(n: Int, links: [[Int]], source: Int) -> Int {
        var graph: [[(to: Int, delay: Int)]] = Array(repeating: [], count: n)
        for link in links {
            graph[link[0]].append((link[1], link[2]))
        }
        var arrival = Array(repeating: Int.max, count: n)
        arrival[source] = 0
        var heap = Heap<(time: Int, server: Int)>(areInIncreasingOrder: { $0.time < $1.time })
        heap.insert((0, source))
        var settled = 0
        var latest = 0
        while let (time, server) = heap.pop() {
            if time > arrival[server] { continue }      // stale entry
            settled += 1
            latest = time
            for (next, delay) in graph[server] where time + delay < arrival[next] {
                arrival[next] = time + delay
                heap.insert((arrival[next], next))
            }
        }
        return settled == n ? latest : -1
    }
}
