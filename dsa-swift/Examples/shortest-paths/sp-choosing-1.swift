// Generated from src/dsa/content/lessons/shortest-paths/sp-choosing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A DAG with negative edges: (from, to, weight). No cycles, so no negative cycles either.
let names = ["S", "A", "B", "C", "D"]
let edges = [(0, 1, 3), (0, 2, 6), (1, 2, -4), (1, 3, 2), (2, 3, 1), (3, 4, -2), (2, 4, 5)]
var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: names.count)
var inDegree = Array(repeating: 0, count: names.count)
for (a, b, w) in edges {
    graph[a].append((b, w))
    inDegree[b] += 1
}

// Kahn's algorithm gives an order where every edge points forwards
var order: [Int] = []
var ready = (0..<names.count).filter { inDegree[$0] == 0 }
while let vertex = ready.popLast() {
    order.append(vertex)
    for (next, _) in graph[vertex] {
        inDegree[next] -= 1
        if inDegree[next] == 0 { ready.append(next) }
    }
}

// Relax each vertex's edges once, in that order: O(V + E), negative weights welcome
let infinity = Int.max / 2
var distance = Array(repeating: infinity, count: names.count)
distance[0] = 0
for vertex in order where distance[vertex] != infinity {
    for (next, weight) in graph[vertex] {
        distance[next] = min(distance[next], distance[vertex] + weight)
    }
}
print("order:", order.map { names[$0] }.joined(separator: " "))
print(zip(names, distance).map { "\($0) \($1)" }.joined(separator: ", "))
