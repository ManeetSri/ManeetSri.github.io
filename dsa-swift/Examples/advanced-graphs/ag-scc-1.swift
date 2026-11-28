// Generated from src/dsa/content/lessons/advanced-graphs/ag-scc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Kosaraju's algorithm: a DFS that records finishing order, then a second pass on the reversed graph
func stronglyConnectedComponents(_ n: Int, _ edges: [[Int]]) -> [[Int]] {
    var graph = [[Int]](repeating: [], count: n)
    var reversed = [[Int]](repeating: [], count: n)
    for edge in edges {
        graph[edge[0]].append(edge[1])
        reversed[edge[1]].append(edge[0])          // the same edge, pointing the other way
    }

    // Pass 1: DFS over the whole graph, recording each vertex as it finishes
    var visited = [Bool](repeating: false, count: n)
    var finished: [Int] = []
    func firstPass(_ v: Int) {
        visited[v] = true
        for w in graph[v] where !visited[w] {
            firstPass(w)
        }
        finished.append(v)                         // everything reachable from v is done
    }
    for v in 0..<n where !visited[v] {
        firstPass(v)
    }
    print("finishing order:", finished)

    // Pass 2: on the reversed graph, latest finisher first. Each search claims one component.
    var claimed = [Bool](repeating: false, count: n)
    var components: [[Int]] = []
    func secondPass(_ v: Int) {
        claimed[v] = true
        components[components.count - 1].append(v)
        for w in reversed[v] where !claimed[w] {
            secondPass(w)
        }
    }
    for v in finished.reversed() where !claimed[v] {
        components.append([])
        secondPass(v)
    }
    return components
}

let edges = [[0, 1], [0, 7], [1, 2], [1, 3], [2, 0], [2, 4], [3, 4], [4, 5], [5, 3], [5, 6], [6, 7], [7, 6]]
let components = stronglyConnectedComponents(8, edges)
print("components:", components)
print("sorted:", components.map { $0.sorted() })
