// Generated from src/dsa/content/lessons/graph-basics/graph-dense-sparse.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Undirected roads [from, to, price]; some pairs are listed more than once
let n = 3
let roads = [[0, 1, 7], [1, 2, 4], [1, 0, 5], [0, 1, 9], [2, 2, 1]]

var cheapest = Array(repeating: [Int: Int](), count: n)     // cheapest[u][v] is the best price
for road in roads {
    let (u, v, price) = (road[0], road[1], road[2])
    if u == v { continue }                                   // a self-loop is never on a best route
    cheapest[u][v] = min(cheapest[u][v] ?? Int.max, price)
    cheapest[v][u] = min(cheapest[v][u] ?? Int.max, price)
}
for u in 0..<n {
    let listed = cheapest[u].keys.sorted().map { "\($0) for \(cheapest[u][$0]!)" }
    print(u, listed)
}
