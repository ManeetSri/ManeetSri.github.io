// Reference solution: Critical cables. A cable is critical exactly when it's a bridge. One DFS gives
// every server a discovery time `disc` and a low-link `low`: the earliest discovery time reachable from
// its DFS subtree using one cable that isn't a tree edge. A tree cable parent–child is a bridge when
// low[child] > disc[parent]: nothing below the child can reach the parent or above without it.
// The DFS skips the cable it arrived on by its id, not by the parent server, so a second parallel cable
// counts as a way back and neither copy is critical. An explicit stack replaces recursion so a chain of
// 100,000 servers can't overflow the call stack. O(V + E) time and space, plus sorting the answer.

public enum CriticalCables {
    public static func find(_ n: Int, _ cables: [[Int]]) -> [[Int]] {
        var adjacency = [[(to: Int, id: Int)]](repeating: [], count: n)
        for (id, cable) in cables.enumerated() {
            adjacency[cable[0]].append((cable[1], id))
            adjacency[cable[1]].append((cable[0], id))
        }

        var disc = [Int](repeating: -1, count: n)      // -1 means not discovered yet
        var low = [Int](repeating: 0, count: n)
        var timer = 0
        var critical: [[Int]] = []
        // Each frame: a server, the cable it was reached by (-1 for a root), and the next neighbour to try
        var frames: [(server: Int, viaCable: Int, next: Int)] = []

        for root in 0..<n where disc[root] == -1 {
            disc[root] = timer
            low[root] = timer
            timer += 1
            frames.append((root, -1, 0))

            while let frame = frames.last {
                let u = frame.server
                if frame.next < adjacency[u].count {
                    frames[frames.count - 1].next += 1
                    let (v, id) = adjacency[u][frame.next]
                    if id == frame.viaCable { continue }   // not back along the same cable
                    if disc[v] == -1 {
                        disc[v] = timer
                        low[v] = timer
                        timer += 1
                        frames.append((v, id, 0))
                    } else {
                        low[u] = min(low[u], disc[v])      // a back edge to an ancestor
                    }
                } else {
                    frames.removeLast()
                    if let parent = frames.last?.server {
                        low[parent] = min(low[parent], low[u])
                        if low[u] > disc[parent] {
                            critical.append([min(parent, u), max(parent, u)])
                        }
                    }
                }
            }
        }
        return critical.sorted { $0.lexicographicallyPrecedes($1) }
    }
}
