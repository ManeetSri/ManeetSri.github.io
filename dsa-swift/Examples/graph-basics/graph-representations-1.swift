// Generated from src/dsa/content/lessons/graph-basics/graph-representations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 5
let edges = [[0, 1], [0, 2], [1, 2], [1, 3], [3, 4]]

// Adjacency matrix: n × n, every entry false to start
var matrix = Array(repeating: Array(repeating: false, count: n), count: n)
// Adjacency list: one empty list per vertex
var adjacency = Array(repeating: [Int](), count: n)

for edge in edges {
    let (u, v) = (edge[0], edge[1])
    matrix[u][v] = true
    matrix[v][u] = true                  // undirected: mirror it
    adjacency[u].append(v)
    adjacency[v].append(u)               // undirected: both ends
}

for u in 0..<n {
    let row = matrix[u].map { $0 ? "1" : "." }.joined(separator: " ")
    print(u, "|", row, "|", adjacency[u])
}
print("edge 1–3?", matrix[1][3], " edge 2–4?", matrix[2][4])
print("neighbours of 1:", adjacency[1])
print("list entries:", adjacency.map(\.count).reduce(0, +), "for", edges.count, "edges")
