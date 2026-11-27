// Generated from src/dsa/content/lessons/shortest-paths/sp-bellman-ford.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let infinity = Int.max / 2

/// Shortest distances from source, or nil if a negative cycle can be reached from it
func bellmanFord(vertexCount: Int, edges: [(Int, Int, Int)], source: Int) -> [Int]? {
    var distance = Array(repeating: infinity, count: vertexCount)
    distance[source] = 0
    for _ in 1..<vertexCount {
        for (from, to, weight) in edges where distance[from] != infinity {
            distance[to] = min(distance[to], distance[from] + weight)
        }
    }
    // Round V: nothing should improve now. If something does, a cycle keeps paying.
    for (from, to, weight) in edges where distance[from] != infinity {
        if distance[from] + weight < distance[to] {
            return nil
        }
    }
    return distance
}

func report(_ result: [Int]?) {
    if let distance = result {
        print(distance.map { $0 == infinity ? "∞" : String($0) })
    } else {
        print("negative cycle reachable")
    }
}

// 1 → 2 → 3 → 1 is a loop of 2 − 4 + 1 = −1, and 0 leads into it
let looping = [(0, 1, 1), (1, 2, 2), (2, 3, -4), (3, 1, 1), (3, 4, 2)]
report(bellmanFord(vertexCount: 5, edges: looping, source: 0))

// The same loop, but nothing leads into it from 0
let cutOff = [(0, 4, 7), (1, 2, 2), (2, 3, -4), (3, 1, 1)]
report(bellmanFord(vertexCount: 5, edges: cutOff, source: 0))

/// Is there a negative cycle anywhere? Start every vertex at 0, as if a new source had a 0-weight edge to each.
func hasNegativeCycle(vertexCount: Int, edges: [(Int, Int, Int)]) -> Bool {
    var distance = Array(repeating: 0, count: vertexCount)
    for _ in 1..<vertexCount {
        for (from, to, weight) in edges {
            distance[to] = min(distance[to], distance[from] + weight)
        }
    }
    return edges.contains { from, to, weight in distance[from] + weight < distance[to] }
}
print(hasNegativeCycle(vertexCount: 5, edges: cutOff))
