// Generated from src/dsa/content/lessons/advanced-graphs/ag-bridges.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Bridges and articulation points with discovery times and low-links
func cutEdgesAndVertices(_ n: Int, _ edges: [[Int]]) -> (bridges: [[Int]], cutVertices: [Int]) {
    var adjacency = [[(to: Int, id: Int)]](repeating: [], count: n)
    for (id, edge) in edges.enumerated() {
        adjacency[edge[0]].append((edge[1], id))
        adjacency[edge[1]].append((edge[0], id))
    }
    var disc = [Int](repeating: -1, count: n)      // discovery time; -1 means not visited yet
    var low = [Int](repeating: 0, count: n)
    var timer = 0
    var bridges: [[Int]] = []
    var isCut = [Bool](repeating: false, count: n)

    func visit(_ u: Int, arrivedBy edge: Int) {
        disc[u] = timer
        low[u] = timer
        timer += 1
        var children = 0
        for (v, id) in adjacency[u] where id != edge {    // skip only the edge we came in on
            if disc[v] == -1 {
                children += 1
                visit(v, arrivedBy: id)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u] { bridges.append([u, v]) }
                if edge != -1 && low[v] >= disc[u] { isCut[u] = true }
            } else {
                low[u] = min(low[u], disc[v])             // a back edge to an ancestor
            }
        }
        if edge == -1 && children >= 2 { isCut[u] = true } // the root: two or more DFS children
    }

    for v in 0..<n where disc[v] == -1 {
        visit(v, arrivedBy: -1)
    }
    print("disc:", disc)
    print("low: ", low)
    return (bridges, (0..<n).filter { isCut[$0] })
}

let edges = [[0, 1], [0, 2], [1, 2], [1, 3], [3, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
let result = cutEdgesAndVertices(8, edges)
print("bridges:", result.bridges)
print("articulation points:", result.cutVertices)
