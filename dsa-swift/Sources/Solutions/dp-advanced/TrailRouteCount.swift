// Reference solution: Counting trail routes. Path counting on a DAG: ways[v] = the sum of ways[u] over
// every trail u → v, with ways[start] = 1. Visiting junctions in a topological order (Kahn's algorithm)
// makes each ways[u] final before any trail out of u is used, and it's a loop, so a 100,000-junction
// chain is fine. Every addition is reduced modulo 1,000,000,007, which keeps the numbers small.
// O(n + m) time and space.

public enum TrailRouteCount {
    public static func countRoutes(n: Int, trails: [[Int]], start: Int, finish: Int) -> Int {
        let mod = 1_000_000_007
        var outgoing = [[Int]](repeating: [], count: n)
        var inDegree = [Int](repeating: 0, count: n)
        for trail in trails {
            outgoing[trail[0]].append(trail[1])
            inDegree[trail[1]] += 1
        }
        var order = (0..<n).filter { inDegree[$0] == 0 }
        var ways = [Int](repeating: 0, count: n)
        ways[start] = 1
        var head = 0
        while head < order.count {
            let u = order[head]
            head += 1
            for v in outgoing[u] {
                ways[v] = (ways[v] + ways[u]) % mod     // ways[u] is final: everything into u came earlier
                inDegree[v] -= 1
                if inDegree[v] == 0 { order.append(v) }
            }
        }
        return ways[finish]
    }
}
