// Generated from src/dsa/content/lessons/shortest-paths/sp-weighted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A weighted, undirected graph as an adjacency list: graph[v] holds (to, weight) pairs
let names = ["home", "park", "shop", "school"]
var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: names.count)

func addRoad(_ a: Int, _ b: Int, minutes: Int) {
    graph[a].append((b, minutes))
    graph[b].append((a, minutes))             // undirected: store both directions
}
addRoad(0, 3, minutes: 10)                    // home – school, the busy main road
addRoad(0, 1, minutes: 2)
addRoad(1, 2, minutes: 3)
addRoad(2, 3, minutes: 2)

// BFS from home counts edges, and ignores the weights
var hops = Array(repeating: -1, count: names.count)
var minutesOnBFSPath = Array(repeating: 0, count: names.count)
hops[0] = 0
var queue = [0]
var head = 0
while head < queue.count {
    let vertex = queue[head]
    head += 1
    for edge in graph[vertex] where hops[edge.to] == -1 {
        hops[edge.to] = hops[vertex] + 1
        minutesOnBFSPath[edge.to] = minutesOnBFSPath[vertex] + edge.weight
        queue.append(edge.to)
    }
}
for vertex in 1..<names.count {
    print("\(names[vertex]): \(hops[vertex]) edge(s), \(minutesOnBFSPath[vertex]) minutes on BFS's path")
}
print("home → park → shop → school takes", 2 + 3 + 2, "minutes")
