// Generated from src/dsa/content/lessons/advanced-graphs/ag-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The same matching as a max flow: source → workers → jobs → sink, every capacity 1
let canDo = [[0, 1], [1, 2], [2, 3], [0]]
let workerCount = 4, jobCount = 4
let source = 0, sink = workerCount + jobCount + 1
func workerNode(_ w: Int) -> Int { 1 + w }
func jobNode(_ j: Int) -> Int { 1 + workerCount + j }

var residual = [[Int]](repeating: [Int](repeating: 0, count: sink + 1), count: sink + 1)
for w in 0..<workerCount {
    residual[source][workerNode(w)] = 1
    for j in canDo[w] { residual[workerNode(w)][jobNode(j)] = 1 }
}
for j in 0..<jobCount { residual[jobNode(j)][sink] = 1 }

var flow = 0
while true {
    var parent = [Int](repeating: -1, count: sink + 1)
    parent[source] = source
    var queue = [source], head = 0
    while head < queue.count && parent[sink] == -1 {
        let u = queue[head]
        head += 1
        for v in residual.indices where parent[v] == -1 && residual[u][v] > 0 {
            parent[v] = u
            queue.append(v)
        }
    }
    if parent[sink] == -1 { break }
    var v = sink
    while v != source {                              // every bottleneck is 1
        residual[parent[v]][v] -= 1
        residual[v][parent[v]] += 1
        v = parent[v]
    }
    flow += 1
}
print("max flow:", flow)
// A worker → job edge carries flow exactly when its backward residual is 1
for w in 0..<workerCount {
    for j in canDo[w] where residual[jobNode(j)][workerNode(w)] == 1 {
        print("worker \(w) → job \(j)")
    }
}
