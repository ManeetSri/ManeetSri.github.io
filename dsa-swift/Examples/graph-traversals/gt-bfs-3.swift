// Generated from src/dsa/content/lessons/graph-traversals/gt-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let edges = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
let vertexCount = 9
var neighbours = Array(repeating: [Int](), count: vertexCount)
for edge in edges {
    neighbours[edge[0]].append(edge[1])
    neighbours[edge[1]].append(edge[0])
}
for vertex in neighbours.indices {
    neighbours[vertex].sort()
}

func shortestPath(from start: Int, to goal: Int) -> [Int] {
    var parent = Array(repeating: -1, count: vertexCount)   // -1: not seen yet
    parent[start] = start                               // the start is its own parent
    var queue = [start]
    var head = 0
    while head < queue.count && parent[goal] == -1 {   // stop once the goal is reached
        let vertex = queue[head]
        head += 1
        for next in neighbours[vertex] where parent[next] == -1 {
            parent[next] = vertex                       // reached next from vertex
            queue.append(next)
        }
    }
    guard parent[goal] != -1 else { return [] }        // never reached
    var path = [goal]
    while path[path.count - 1] != start {
        path.append(parent[path[path.count - 1]])      // step back towards the start
    }
    return path.reversed()
}

print(shortestPath(from: 0, to: 7))
print(shortestPath(from: 0, to: 4))
print(shortestPath(from: 7, to: 2))
print(shortestPath(from: 0, to: 8))
print(shortestPath(from: 3, to: 3))
