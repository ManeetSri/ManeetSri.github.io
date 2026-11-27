// Generated from src/dsa/content/lessons/advanced-graphs/ag-scc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Component ids from Kosaraju (topological order), then the condensation DAG
func componentIds(_ n: Int, _ edges: [[Int]]) -> [Int] {
    var graph = [[Int]](repeating: [], count: n)
    var reversed = [[Int]](repeating: [], count: n)
    for edge in edges {
        graph[edge[0]].append(edge[1])
        reversed[edge[1]].append(edge[0])
    }
    var visited = [Bool](repeating: false, count: n)
    var finished: [Int] = []
    func firstPass(_ v: Int) {
        visited[v] = true
        for w in graph[v] where !visited[w] { firstPass(w) }
        finished.append(v)
    }
    for v in 0..<n where !visited[v] { firstPass(v) }

    var component = [Int](repeating: -1, count: n)
    var count = 0
    func secondPass(_ v: Int) {
        component[v] = count
        for w in reversed[v] where component[w] == -1 { secondPass(w) }
    }
    for v in finished.reversed() where component[v] == -1 {
        secondPass(v)
        count += 1
    }
    return component
}

let n = 8
let edges = [[0, 1], [0, 7], [1, 2], [1, 3], [2, 0], [2, 4], [3, 4], [4, 5], [5, 3], [5, 6], [6, 7], [7, 6]]
let component = componentIds(n, edges)
let count = component.max()! + 1
print("component of each vertex:", component)

// One edge between two components, however many original edges join them
var dagEdges = Set<[Int]>()
for edge in edges where component[edge[0]] != component[edge[1]] {
    dagEdges.insert([component[edge[0]], component[edge[1]]])
}
print("condensation edges:", dagEdges.sorted { $0.lexicographicallyPrecedes($1) })

var inDegree = [Int](repeating: 0, count: count)
var outDegree = [Int](repeating: 0, count: count)
for edge in dagEdges {
    outDegree[edge[0]] += 1
    inDegree[edge[1]] += 1
}
let sources = (0..<count).filter { inDegree[$0] == 0 }
let sinks = (0..<count).filter { outDegree[$0] == 0 }
print("sources:", sources, "sinks:", sinks)
print("one-way edges to add to make it strongly connected:", count == 1 ? 0 : max(sources.count, sinks.count))
