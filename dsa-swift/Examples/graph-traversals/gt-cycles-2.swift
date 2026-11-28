// Generated from src/dsa/content/lessons/graph-traversals/gt-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Directed edges: [a, b] means a → b
func outgoing(_ vertexCount: Int, _ edges: [[Int]]) -> [[Int]] {
    var result = Array(repeating: [Int](), count: vertexCount)
    for edge in edges {
        result[edge[0]].append(edge[1])
    }
    return result
}

/// WRONG for directed graphs: treats "reached something already visited" as a cycle
func naiveHasCycle(_ vertexCount: Int, _ edges: [[Int]]) -> Bool {
    let next = outgoing(vertexCount, edges)
    var visited = Array(repeating: false, count: vertexCount)
    func visit(_ vertex: Int) -> Bool {
        visited[vertex] = true
        for neighbour in next[vertex] {
            if visited[neighbour] || visit(neighbour) { return true }
        }
        return false
    }
    for start in 0..<vertexCount where !visited[start] {
        if visit(start) { return true }
    }
    return false
}

/// Three colours: 0 white (unvisited), 1 grey (on the current path), 2 black (finished)
func hasCycle(_ vertexCount: Int, _ edges: [[Int]]) -> Bool {
    let next = outgoing(vertexCount, edges)
    var colour = Array(repeating: 0, count: vertexCount)
    func visit(_ vertex: Int) -> Bool {
        colour[vertex] = 1                              // entering: now on the path
        for neighbour in next[vertex] {
            if colour[neighbour] == 1 { return true }   // back to the current path: a cycle
            if colour[neighbour] == 0 && visit(neighbour) { return true }
        }
        colour[vertex] = 2                              // finished: everything below it is explored
        return false
    }
    for start in 0..<vertexCount where colour[start] == 0 {
        if visit(start) { return true }
    }
    return false
}

let graphs: [(String, Int, [[Int]])] = [
    ("diamond", 4, [[0, 1], [0, 2], [1, 3], [2, 3]]),
    ("triangle", 3, [[0, 1], [1, 2], [2, 0]]),
    ("self-loop", 2, [[0, 1], [1, 1]]),
    ("two ways in", 3, [[0, 2], [1, 2]]),
]
for (name, count, edges) in graphs {
    print(name, "naive:", naiveHasCycle(count, edges), "colours:", hasCycle(count, edges))
}
