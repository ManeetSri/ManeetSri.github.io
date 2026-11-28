// Generated from src/dsa/content/lessons/advanced-graphs/ag-max-flow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Dinic's algorithm: BFS levels, then a blocking flow along edges that go one level further
struct FlowNetwork {
    var head: [Int] = []                          // head[e]: where edge e leads
    var residual: [Int] = []                      // residual[e]: how much more e can carry
    var edgesOut: [[Int]]

    init(vertices: Int) {
        edgesOut = [[Int]](repeating: [], count: vertices)
    }

    // Edge e and its reverse are stored side by side, at e and e ^ 1
    mutating func addPipe(_ from: Int, _ to: Int, _ capacity: Int) {
        edgesOut[from].append(head.count)
        head.append(to)
        residual.append(capacity)
        edgesOut[to].append(head.count)
        head.append(from)
        residual.append(0)
    }

    mutating func maxFlow(from source: Int, to sink: Int) -> Int {
        let n = edgesOut.count
        var total = 0
        var phase = 0
        while true {
            // 1. BFS: each vertex's level is its distance from the source in the residual graph
            var level = [Int](repeating: -1, count: n)
            level[source] = 0
            var queue = [source], front = 0
            while front < queue.count {
                let u = queue[front]
                front += 1
                for e in edgesOut[u] where residual[e] > 0 && level[head[e]] == -1 {
                    level[head[e]] = level[u] + 1
                    queue.append(head[e])
                }
            }
            if level[sink] == -1 { return total }

            // 2. DFS: push flow along level-increasing edges until none gets through
            var nextEdge = [Int](repeating: 0, count: n)   // edges before this are useless this phase
            func push(_ u: Int, _ limit: Int) -> Int {
                if u == sink { return limit }
                while nextEdge[u] < edgesOut[u].count {
                    let e = edgesOut[u][nextEdge[u]]
                    if residual[e] > 0 && level[head[e]] == level[u] + 1 {
                        let pushed = push(head[e], min(limit, residual[e]))
                        if pushed > 0 {
                            residual[e] -= pushed
                            residual[e ^ 1] += pushed
                            return pushed
                        }
                    }
                    nextEdge[u] += 1
                }
                return 0
            }
            var phaseFlow = 0
            while true {
                let pushed = push(source, Int.max)
                if pushed == 0 { break }
                phaseFlow += pushed
            }
            phase += 1
            total += phaseFlow
            print("phase \(phase): sink at level \(level[sink]), pushed \(phaseFlow), total \(total)")
        }
    }
}

// S=0, A=1, B=2, C=3, D=4, T=5: the lesson's network
var network = FlowNetwork(vertices: 6)
for (from, to, capacity) in [(0, 1, 7), (0, 2, 9), (1, 2, 3), (1, 3, 6), (2, 4, 8), (4, 3, 2), (3, 5, 8), (4, 5, 7)] {
    network.addPipe(from, to, capacity)
}
print("max flow:", network.maxFlow(from: 0, to: 5))
