// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// BFS: fewest edges from one source (or many), with the path rebuilt from parent links
func adjacency(_ count: Int, _ edges: [(Int, Int)]) -> [[Int]] {
    var neighbours = Array(repeating: [Int](), count: count)
    for (a, b) in edges {
        neighbours[a].append(b)
        neighbours[b].append(a)                   // drop this line for one-way edges
    }
    return neighbours
}

func bfs(_ neighbours: [[Int]], from sources: [Int]) -> (distance: [Int], parent: [Int]) {
    var distance = Array(repeating: -1, count: neighbours.count)   // -1: not reached yet
    var parent = Array(repeating: -1, count: neighbours.count)
    var queue = sources
    var head = 0
    for source in sources { distance[source] = 0 }
    while head < queue.count {
        let node = queue[head]
        head += 1
        for next in neighbours[node] where distance[next] == -1 {
            distance[next] = distance[node] + 1   // mark when queued, never twice
            parent[next] = node
            queue.append(next)
        }
    }
    return (distance, parent)
}

func path(to target: Int, _ parent: [Int]) -> [Int] {
    var route = [target]
    while parent[route[route.count - 1]] != -1 {
        route.append(parent[route[route.count - 1]])
    }
    return route.reversed()
}

let graph = adjacency(7, [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (4, 5), (2, 6)])
let (distance, parent) = bfs(graph, from: [0])
print(distance)
print(path(to: 5, parent))
print(bfs(graph, from: [5, 6]).distance)          // multi-source: distance to the nearer of 5 and 6
