// Reference solution: Pipeline max flow. Edmonds–Karp: repeatedly find the augmenting path with the
// fewest pipes by BFS in the residual graph, and push its bottleneck along it. Each pipe is stored as
// a pair of residual edges side by side, forward at an even index i and backward at i ^ 1, so pushing
// flow is `residual[e] -= f; residual[e ^ 1] += f`, and parallel or opposite pipes need no special
// handling. O(V · E²) time whatever the capacities, O(V + E) space.

public enum PipelineMaxFlow {
    public static func maxFlow(_ n: Int, _ pipes: [[Int]], from source: Int, to sink: Int) -> Int {
        var head: [Int] = []                           // head[e]: the station edge e leads to
        var residual: [Int] = []                       // residual[e]: how much more e can carry
        var edgesOut = [[Int]](repeating: [], count: n)
        for pipe in pipes {
            edgesOut[pipe[0]].append(head.count)
            head.append(pipe[1])
            residual.append(pipe[2])
            edgesOut[pipe[1]].append(head.count)       // the backward edge starts with nothing to undo
            head.append(pipe[0])
            residual.append(0)
        }

        var total = 0
        while true {
            // BFS from the source, remembering the edge that first reached each station
            var reachedBy = [Int](repeating: -1, count: n)
            var reached = [Bool](repeating: false, count: n)
            reached[source] = true
            var queue = [source]
            var front = 0
            while front < queue.count && !reached[sink] {
                let u = queue[front]
                front += 1
                for e in edgesOut[u] where residual[e] > 0 && !reached[head[e]] {
                    reached[head[e]] = true
                    reachedBy[head[e]] = e
                    queue.append(head[e])
                }
            }
            if !reached[sink] { return total }         // no augmenting path: the flow is maximum

            // Walk back from the sink to find the bottleneck, then push that much along the path
            var bottleneck = Int.max
            var station = sink
            while station != source {
                let e = reachedBy[station]
                bottleneck = min(bottleneck, residual[e])
                station = head[e ^ 1]
            }
            station = sink
            while station != source {
                let e = reachedBy[station]
                residual[e] -= bottleneck
                residual[e ^ 1] += bottleneck
                station = head[e ^ 1]
            }
            total += bottleneck
        }
    }
}
