// Generated from src/dsa/content/lessons/advanced-graphs/ag-max-flow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Edmonds–Karp on an adjacency matrix: BFS for the shortest augmenting path, push its bottleneck, repeat
func maxFlow(_ capacity: [[Int]], from source: Int, to sink: Int, names: [String]) -> Int {
    var residual = capacity                       // residual[u][v]: how much more can go u→v
    var total = 0
    while true {
        var parent = [Int](repeating: -1, count: capacity.count)
        parent[source] = source
        var queue = [source], head = 0
        while head < queue.count && parent[sink] == -1 {      // BFS: the shortest augmenting path
            let u = queue[head]
            head += 1
            for v in residual.indices where parent[v] == -1 && residual[u][v] > 0 {
                parent[v] = u
                queue.append(v)
            }
        }
        if parent[sink] == -1 { break }           // no path left: the flow is maximum

        var path = [sink]
        var bottleneck = Int.max
        var v = sink
        while v != source {
            bottleneck = min(bottleneck, residual[parent[v]][v])
            v = parent[v]
            path.append(v)
        }
        v = sink
        while v != source {
            residual[parent[v]][v] -= bottleneck
            residual[v][parent[v]] += bottleneck  // so this flow can be pushed back later
            v = parent[v]
        }
        total += bottleneck
        print("push \(bottleneck) along \(path.reversed().map { names[$0] }.joined(separator: "→")), total \(total)")
    }

    // The minimum cut: everything still reachable from the source in the residual graph
    var reachable = [Bool](repeating: false, count: capacity.count)
    reachable[source] = true
    var stack = [source]
    while let u = stack.popLast() {
        for v in residual.indices where !reachable[v] && residual[u][v] > 0 {
            reachable[v] = true
            stack.append(v)
        }
    }
    var cut: [String] = []
    for u in capacity.indices where reachable[u] {
        for v in capacity.indices where !reachable[v] && capacity[u][v] > 0 {
            cut.append("\(names[u])→\(names[v]) (\(capacity[u][v]))")
        }
    }
    print("source side:", capacity.indices.filter { reachable[$0] }.map { names[$0] }, "cut:", cut.joined(separator: ", "))
    return total
}

func network(_ names: [String], _ pipes: [(String, String, Int)]) -> [[Int]] {
    var capacity = [[Int]](repeating: [Int](repeating: 0, count: names.count), count: names.count)
    for (from, to, amount) in pipes {
        capacity[names.firstIndex(of: from)!][names.firstIndex(of: to)!] += amount
    }
    return capacity
}

let names = ["S", "A", "B", "C", "D", "T"]
let pipes = [("S", "A", 7), ("S", "B", 9), ("A", "B", 3), ("A", "C", 6),
             ("B", "D", 8), ("D", "C", 2), ("C", "T", 8), ("D", "T", 7)]
print("max flow:", maxFlow(network(names, pipes), from: 0, to: 5, names: names))
