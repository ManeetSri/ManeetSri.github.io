// Generated from src/dsa/content/lessons/advanced-graphs/ag-bridges.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two ways to avoid walking straight back to the parent
func bridges(_ n: Int, _ edges: [[Int]], skipParentVertex: Bool) -> [[Int]] {
    var adjacency = [[(to: Int, id: Int)]](repeating: [], count: n)
    for (id, edge) in edges.enumerated() {
        adjacency[edge[0]].append((edge[1], id))
        adjacency[edge[1]].append((edge[0], id))
    }
    var disc = [Int](repeating: -1, count: n)
    var low = [Int](repeating: 0, count: n)
    var timer = 0
    var found: [[Int]] = []

    func visit(_ u: Int, parent: Int, arrivedBy edge: Int) {
        disc[u] = timer
        low[u] = timer
        timer += 1
        for (v, id) in adjacency[u] {
            if skipParentVertex ? v == parent : id == edge { continue }
            if disc[v] == -1 {
                visit(v, parent: u, arrivedBy: id)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u] { found.append([u, v]) }
            } else {
                low[u] = min(low[u], disc[v])
            }
        }
    }
    for v in 0..<n where disc[v] == -1 {
        visit(v, parent: -1, arrivedBy: -1)
    }
    return found
}

let doubled = [[0, 1], [0, 1], [1, 2]]               // two cables between 0 and 1
print("skip the parent vertex:", bridges(3, doubled, skipParentVertex: true))
print("skip the edge's id:    ", bridges(3, doubled, skipParentVertex: false))
