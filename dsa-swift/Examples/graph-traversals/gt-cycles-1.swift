// Generated from src/dsa/content/lessons/graph-traversals/gt-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Does this undirected graph contain a cycle? A visited neighbour that isn't your parent closes one.
func hasUndirectedCycle(_ vertexCount: Int, _ edges: [[Int]]) -> Bool {
    var neighbours = Array(repeating: [Int](), count: vertexCount)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var parent = Array(repeating: -2, count: vertexCount)   // -2: not visited, -1: no parent
    for start in 0..<vertexCount where parent[start] == -2 {
        parent[start] = -1
        var stack = [start]
        while let vertex = stack.popLast() {
            for next in neighbours[vertex] {
                if parent[next] == -2 {
                    parent[next] = vertex               // a tree edge: next is new
                    stack.append(next)
                } else if next != parent[vertex] {
                    return true                         // visited, and not the way we came in
                }
            }
        }
    }
    return false
}

let tree = [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5]]
print(hasUndirectedCycle(6, tree))
print(hasUndirectedCycle(6, tree + [[4, 5]]))
print(hasUndirectedCycle(2, [[0, 1]]))
print(hasUndirectedCycle(5, [[0, 1], [2, 3], [3, 4], [4, 2]]))
print(hasUndirectedCycle(3, [[0, 1], [2, 2]]))
