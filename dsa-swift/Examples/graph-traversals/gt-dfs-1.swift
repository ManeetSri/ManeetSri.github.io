// Generated from src/dsa/content/lessons/graph-traversals/gt-dfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let edges = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
var neighbours = Array(repeating: [Int](), count: 8)
for edge in edges {
    neighbours[edge[0]].append(edge[1])
    neighbours[edge[1]].append(edge[0])
}
for vertex in neighbours.indices {
    neighbours[vertex].sort()
}

func dfs(from start: Int) -> [Int] {
    var visited = Array(repeating: false, count: neighbours.count)
    var order: [Int] = []
    func visit(_ vertex: Int) {
        visited[vertex] = true
        order.append(vertex)
        for next in neighbours[vertex] where !visited[next] {   // checked as the loop reaches it
            visit(next)
        }
    }
    visit(start)
    return order
}

print(dfs(from: 0))
print(dfs(from: 7))
