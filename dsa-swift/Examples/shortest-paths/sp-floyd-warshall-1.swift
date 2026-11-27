// Generated from src/dsa/content/lessons/shortest-paths/sp-floyd-warshall.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let infinity = Int.max / 2
let n = 4
// Directed edges (from, to, weight)
let edges = [(0, 1, 3), (0, 2, 8), (1, 2, 2), (2, 3, 1), (3, 0, 4)]

var dist = Array(repeating: Array(repeating: infinity, count: n), count: n)
for i in 0..<n {
    dist[i][i] = 0
}
for (from, to, weight) in edges {
    dist[from][to] = min(dist[from][to], weight)   // keep the cheapest of parallel edges
}

func show(_ matrix: [[Int]]) {
    for row in matrix {
        let cells = row.map { $0 == infinity ? "∞" : String($0) }
        print(cells.map { String(repeating: " ", count: 3 - $0.count) + $0 }.joined())
    }
}

for k in 0..<n {                               // k: the newest vertex allowed in the middle
    for i in 0..<n where dist[i][k] < infinity {
        for j in 0..<n where dist[k][j] < infinity && dist[i][k] + dist[k][j] < dist[i][j] {
            dist[i][j] = dist[i][k] + dist[k][j]
        }
    }
    print("allowing 0...\(k) in the middle:")
    show(dist)
}
