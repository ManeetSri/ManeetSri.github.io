// Reference solution: The grand tour. Held–Karp bitmask DP: best[mask][last] is the length of the
// shortest path that starts at city 0, visits exactly the cities in `mask` and ends at `last`. Extend
// each path by one unvisited city at a time; masks only grow, so looping over masks in increasing
// order fills each state before it's used. The tour closes with the road from the last city back to 0.
// The table is one flat array indexed by mask * n + last. O(2ⁿ · n²) time, O(2ⁿ · n) space.

public enum GrandTourPlanner {
    public static func shortestTour(_ distance: [[Int]]) -> Int {
        let n = distance.count
        if n <= 1 { return 0 }
        let full = 1 << n
        let unreached = Int.max / 2
        var best = [Int](repeating: unreached, count: full * n)
        best[1 * n + 0] = 0                            // at city 0, having visited only city 0

        for mask in 1..<full where mask & 1 == 1 {     // every path starts at city 0
            for last in 0..<n where mask & (1 << last) != 0 {
                let cost = best[mask * n + last]
                if cost == unreached { continue }
                for next in 0..<n where mask & (1 << next) == 0 {
                    let state = (mask | (1 << next)) * n + next
                    let candidate = cost + distance[last][next]
                    if candidate < best[state] {
                        best[state] = candidate
                    }
                }
            }
        }

        var shortest = unreached
        for last in 1..<n {
            shortest = min(shortest, best[(full - 1) * n + last] + distance[last][0])
        }
        return shortest
    }
}
