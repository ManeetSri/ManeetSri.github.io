// Generated from src/dsa/content/lessons/topo-sort/topo-dfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Topological order by DFS with an explicit stack: no recursion, so any depth is fine
func topologicalOrder(_ n: Int, _ after: [[Int]]) -> [Int] {
    var visited = Array(repeating: false, count: n)
    var finished: [Int] = []
    finished.reserveCapacity(n)
    for start in 0..<n where !visited[start] {
        visited[start] = true
        var stack = [(vertex: start, nextIndex: 0)]     // a frame: a vertex and its progress
        while let (vertex, index) = stack.last {
            if index < after[vertex].count {
                stack[stack.count - 1].nextIndex += 1    // next time, try the following neighbour
                let next = after[vertex][index]
                if !visited[next] {
                    visited[next] = true
                    stack.append((vertex: next, nextIndex: 0))   // "call" visit(next)
                }
            } else {
                stack.removeLast()                       // "return": all its neighbours are done
                finished.append(vertex)
            }
        }
    }
    return finished.reversed()
}

// A chain 200,000 long: 0 → 1 → 2 → … → 199,999
let n = 200_000
var after = Array(repeating: [Int](), count: n)
for vertex in 0..<(n - 1) {
    after[vertex].append(vertex + 1)
}
let order = topologicalOrder(n, after)
print(order.count, Array(order.prefix(3)), order.last!)
print(topologicalOrder(4, [[1, 2], [3], [3], []]))
