// Generated from src/dsa/content/lessons/advanced-graphs/ag-scc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Tarjan's algorithm: one DFS, a discovery index and a low-link per vertex, and a stack
func tarjan(_ n: Int, _ edges: [[Int]]) -> [[Int]] {
    var graph = [[Int]](repeating: [], count: n)
    for edge in edges {
        graph[edge[0]].append(edge[1])
    }
    var index = [Int](repeating: -1, count: n)     // discovery order; -1 means not visited yet
    var low = [Int](repeating: 0, count: n)
    var onStack = [Bool](repeating: false, count: n)
    var stack: [Int] = []
    var nextIndex = 0
    var components: [[Int]] = []

    func visit(_ v: Int) {
        index[v] = nextIndex
        low[v] = nextIndex
        nextIndex += 1
        stack.append(v)
        onStack[v] = true
        for w in graph[v] {
            if index[w] == -1 {
                visit(w)                           // a tree edge
                low[v] = min(low[v], low[w])
            } else if onStack[w] {
                low[v] = min(low[v], index[w])     // an edge back into an unfinished component
            }                                      // otherwise w's component is finished: ignore it
        }
        if low[v] == index[v] {                    // v is the first vertex of its component
            var component: [Int] = []
            while true {
                let w = stack.removeLast()
                onStack[w] = false
                component.append(w)
                if w == v { break }
            }
            print("\(v) closes \(component.sorted()); stack left: \(stack)")
            components.append(component)
        }
    }

    for v in 0..<n where index[v] == -1 {
        visit(v)
    }
    print("index:", index)
    print("low:  ", low)
    return components
}

let edges = [[0, 1], [0, 7], [1, 2], [1, 3], [2, 0], [2, 4], [3, 4], [4, 5], [5, 3], [5, 6], [6, 7], [7, 6]]
print(tarjan(8, edges).map { $0.sorted() })
