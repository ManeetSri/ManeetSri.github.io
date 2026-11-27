// Generated from src/dsa/content/lessons/shortest-paths/sp-spfa.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// SPFA from source. Returns nil when a negative cycle is reachable.
func spfa(vertexCount: Int, edges: [(Int, Int, Int)], source: Int) -> [Int]? {
    var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: vertexCount)
    for (a, b, w) in edges {
        graph[a].append((b, w))
    }
    let infinity = Int.max / 2
    var distance = Array(repeating: infinity, count: vertexCount)
    var edgesOnPath = Array(repeating: 0, count: vertexCount)   // edges in the best path found to v
    var inQueue = Array(repeating: false, count: vertexCount)
    distance[source] = 0
    var queue = [source]
    var head = 0
    inQueue[source] = true
    while head < queue.count {
        let u = queue[head]
        head += 1
        inQueue[u] = false
        for (v, weight) in graph[u] where distance[u] + weight < distance[v] {
            distance[v] = distance[u] + weight
            edgesOnPath[v] = edgesOnPath[u] + 1
            if edgesOnPath[v] >= vertexCount {           // V edges means a repeated vertex: a paying loop
                print("path to \(v) now has \(edgesOnPath[v]) edges")
                return nil
            }
            if !inQueue[v] {
                queue.append(v)
                inQueue[v] = true
            }
        }
    }
    return distance
}

print(spfa(vertexCount: 4, edges: [(0, 1, 4), (1, 2, -1), (2, 3, 2), (0, 3, 9)], source: 0) as Any)
print(spfa(vertexCount: 4, edges: [(0, 1, 1), (1, 2, 2), (2, 3, -2), (3, 1, -1)], source: 0) as Any)
