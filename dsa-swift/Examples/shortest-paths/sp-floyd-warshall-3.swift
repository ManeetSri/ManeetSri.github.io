// Generated from src/dsa/content/lessons/shortest-paths/sp-floyd-warshall.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let infinity = Int.max / 2

/// Floyd–Warshall, then report which vertices sit on a negative cycle
func verticesOnNegativeCycles(_ n: Int, _ edges: [(Int, Int, Int)]) -> [Int] {
    var dist = Array(repeating: Array(repeating: infinity, count: n), count: n)
    for i in 0..<n {
        dist[i][i] = 0
    }
    for (from, to, weight) in edges {
        dist[from][to] = min(dist[from][to], weight)
    }
    for k in 0..<n {
        for i in 0..<n where dist[i][k] < infinity {
            for j in 0..<n where dist[k][j] < infinity {
                dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
            }
        }
    }
    return (0..<n).filter { dist[$0][$0] < 0 }   // a way back to yourself that costs less than nothing
}

print(verticesOnNegativeCycles(4, [(0, 1, 2), (1, 2, -1), (2, 3, 4), (3, 1, -1)]))
print(verticesOnNegativeCycles(4, [(0, 1, 2), (1, 2, -1), (2, 3, 1), (3, 1, -1)]))
