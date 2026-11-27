// Generated from src/dsa/content/lessons/advanced-graphs/ag-bridges.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Bridges and articulation points with an explicit stack of frames
func cutEdgesAndVertices(_ n: Int, _ edges: [[Int]]) -> (bridges: Int, cutVertices: Int) {
    var adjacency = [[(to: Int, id: Int)]](repeating: [], count: n)
    for (id, edge) in edges.enumerated() {
        adjacency[edge[0]].append((edge[1], id))
        adjacency[edge[1]].append((edge[0], id))
    }
    var disc = [Int](repeating: -1, count: n)
    var low = [Int](repeating: 0, count: n)
    var isCut = [Bool](repeating: false, count: n)
    var timer = 0
    var bridges = 0
    var frames: [(vertex: Int, arrivedBy: Int, next: Int)] = []

    for root in 0..<n where disc[root] == -1 {
        disc[root] = timer
        low[root] = timer
        timer += 1
        var rootChildren = 0
        frames.append((root, -1, 0))
        while let frame = frames.last {
            let u = frame.vertex
            if frame.next < adjacency[u].count {
                frames[frames.count - 1].next += 1
                let (v, id) = adjacency[u][frame.next]
                if id == frame.arrivedBy { continue }
                if disc[v] == -1 {                      // the recursive call
                    if u == root { rootChildren += 1 }
                    disc[v] = timer
                    low[v] = timer
                    timer += 1
                    frames.append((v, id, 0))
                } else {
                    low[u] = min(low[u], disc[v])
                }
            } else {                                    // the return: the parent is the new top
                frames.removeLast()
                guard let parent = frames.last?.vertex else { continue }
                low[parent] = min(low[parent], low[u])
                if low[u] > disc[parent] { bridges += 1 }
                if parent != root && low[u] >= disc[parent] { isCut[parent] = true }
            }
        }
        if rootChildren >= 2 { isCut[root] = true }
    }
    return (bridges, isCut.filter { $0 }.count)
}

let n = 200_000
let line = (0..<(n - 1)).map { [$0, $0 + 1] }
print("a line of 200,000:", cutEdgesAndVertices(n, line))
print("closed into a ring:", cutEdgesAndVertices(n, line + [[n - 1, 0]]))
let lesson = [[0, 1], [0, 2], [1, 2], [1, 3], [3, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
print("the lesson's graph:", cutEdgesAndVertices(8, lesson))
