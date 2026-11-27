// Reference solution: Audit a distance table. The table is exact when two things hold, the two
// properties of relaxation. (1) No road can be relaxed: from a reached place, every road leads to a
// reached place whose claim is no worse than going that way. With the start at 0, that makes every
// claim at most the true distance. (2) Every claim is the length of a real route: the "tight" roads,
// where claim[u] + minutes == claim[v], must reach every claimed place from the start. A BFS along
// tight roads checks it; checking only that each place has *some* tight road in isn't enough, because
// 0-minute roads let a group of places vouch for each other. O(places + roads) time and space.

public enum DistanceTableAudit {
    public static func isExact(places: Int, roads: [[Int]], start: Int, claimed: [Int?]) -> Bool {
        guard claimed[start] == 0 else { return false }
        var graph: [[(to: Int, minutes: Int)]] = Array(repeating: [], count: places)
        for road in roads {
            graph[road[0]].append((road[1], road[2]))
            graph[road[1]].append((road[0], road[2]))             // two-way: both directions
        }
        // (1) Nothing can be relaxed, and nothing reachable is marked unreachable
        for place in 0..<places {
            guard let here = claimed[place] else { continue }
            for road in graph[place] {
                guard let there = claimed[road.to], here + road.minutes >= there else { return false }
            }
        }
        // (2) Every claimed place is reached from the start along tight roads
        var reached = Array(repeating: false, count: places)
        reached[start] = true
        var queue = [start]
        var head = 0
        while head < queue.count {
            let place = queue[head]
            head += 1
            let here = claimed[place]!
            for road in graph[place] where !reached[road.to] && claimed[road.to] == here + road.minutes {
                reached[road.to] = true
                queue.append(road.to)
            }
        }
        return (0..<places).allSatisfy { claimed[$0] == nil || reached[$0] }
    }
}
