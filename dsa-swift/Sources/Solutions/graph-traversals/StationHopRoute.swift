// Reference solution: Fewest stops between stations. BFS from the start over an adjacency list, with
// a head-index queue. parent[s] records the station s was first reached from (-1 means not reached
// yet), so it doubles as the visited mark. The search stops as soon as the goal is reached, then the
// route is rebuilt by following parents back to the start and reversing. O(stations + links) time
// and space.

public enum StationHopRoute {
    public static func route(stations: Int, links: [[Int]], from start: Int, to goal: Int) -> [Int] {
        var neighbours = Array(repeating: [Int](), count: stations)
        for link in links {
            neighbours[link[0]].append(link[1])
            neighbours[link[1]].append(link[0])
        }

        var parent = Array(repeating: -1, count: stations)
        parent[start] = start
        var queue = [start]
        var head = 0
        while head < queue.count && parent[goal] == -1 {
            let station = queue[head]
            head += 1
            for next in neighbours[station] where parent[next] == -1 {
                parent[next] = station                   // mark when enqueued
                queue.append(next)
            }
        }
        guard parent[goal] != -1 else { return [] }

        var route = [goal]
        while route[route.count - 1] != start {
            route.append(parent[route[route.count - 1]])
        }
        return route.reversed()
    }
}
