// Generated from src/dsa/content/lessons/graph-traversals/gt-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The example graph as an adjacency list: neighbours[v] lists v's neighbours, smallest first
let edges = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
let vertexCount = 9                                     // vertex 8 has no edges
var neighbours = Array(repeating: [Int](), count: vertexCount)
for edge in edges {
    neighbours[edge[0]].append(edge[1])
    neighbours[edge[1]].append(edge[0])
}
for vertex in neighbours.indices {
    neighbours[vertex].sort()
}

func bfs(from start: Int) -> (order: [Int], distance: [Int]) {
    var distance = Array(repeating: -1, count: vertexCount)   // -1: not seen yet
    distance[start] = 0
    var queue = [start]
    var head = 0
    while head < queue.count {
        let vertex = queue[head]
        head += 1
        for next in neighbours[vertex] where distance[next] == -1 {
            distance[next] = distance[vertex] + 1        // mark it the moment it's enqueued
            queue.append(next)
        }
    }
    return (queue, distance)                             // the queue holds the visiting order
}

let result = bfs(from: 0)
print("order:", result.order)
print("distance:", result.distance)
