// Reference solution: Groups after each road closure. Union-find can join groups but never split them,
// so run time backwards: start from the network after the last closure (every road that never closes,
// or closes last), and reopen the closed roads in reverse order. Before reopening closure k, the
// component count is the answer for the moment just after closure k. One union per road:
// O((towns + roads) α(towns)) time, O(towns + roads) space.

import DSAKit

public enum StormRoadClosures {
    public static func groupsAfterEachClosure(towns: Int, roads: [[Int]], closures: [Int]) -> [Int] {
        var closes = Array(repeating: false, count: roads.count)
        for road in closures {
            closes[road] = true
        }
        var groups = UnionFind(count: towns)
        for (index, road) in roads.enumerated() where !closes[index] {
            groups.union(road[0], road[1])                       // roads still open after the storm
        }
        var answer = Array(repeating: 0, count: closures.count)
        for k in stride(from: closures.count - 1, through: 0, by: -1) {
            answer[k] = groups.componentCount                    // the network just after closure k
            let road = roads[closures[k]]
            groups.union(road[0], road[1])                       // undo closure k
        }
        return answer
    }
}
