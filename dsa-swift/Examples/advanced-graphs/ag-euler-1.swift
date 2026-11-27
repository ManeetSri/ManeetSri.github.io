// Generated from src/dsa/content/lessons/advanced-graphs/ag-euler.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let edges = [[0, 1], [1, 2], [2, 3], [3, 0], [0, 2], [1, 3], [3, 4], [4, 2]]
let n = 5
var adjacency = [[(to: Int, id: Int)]](repeating: [], count: n)
for (id, edge) in edges.enumerated() {
    adjacency[edge[0]].append((edge[1], id))
    adjacency[edge[1]].append((edge[0], id))
}

// Degree check: an Euler path needs 0 or 2 vertices of odd degree
let odd = (0..<n).filter { adjacency[$0].count % 2 == 1 }
print("degrees:", adjacency.map { $0.count }, "odd:", odd)
let start = odd.first ?? 0                     // start at an odd vertex if there is one

// Hierholzer's algorithm with a stack. `next[v]` skips edges already used from v's side.
var used = [Bool](repeating: false, count: edges.count)
var next = [Int](repeating: 0, count: n)
var stack = [start]
var path: [Int] = []
while let v = stack.last {
    while next[v] < adjacency[v].count && used[adjacency[v][next[v]].id] {
        next[v] += 1                           // this edge was walked from the other end
    }
    if next[v] < adjacency[v].count {
        let (w, id) = adjacency[v][next[v]]
        used[id] = true
        stack.append(w)                        // walk the edge
    } else {
        path.append(stack.removeLast())        // stuck: v is the last vertex among those left
    }
}
print("path:", Array(path.reversed()))
print("edges used:", path.count - 1, "of", edges.count)
