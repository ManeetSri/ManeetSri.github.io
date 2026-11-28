// Generated from src/dsa/content/lessons/advanced-graphs/ag-max-flow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Edmonds–Karp again, on the network where the first path has to be partly undone
func maxFlow(_ capacity: [[Int]], from source: Int, to sink: Int, names: [String]) -> Int {
    var residual = capacity
    var total = 0
    while true {
        var parent = [Int](repeating: -1, count: capacity.count)
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
        if parent[sink] == -1 { return total }
        var steps: [String] = []
        var bottleneck = Int.max
        var v = sink
        while v != source {
            let u = parent[v]
            bottleneck = min(bottleneck, residual[u][v])
            // An edge with no capacity of its own can only be carrying flow back: a cancellation
            steps.append(capacity[u][v] > 0 ? "\(names[u])→\(names[v])" : "\(names[u])→\(names[v]) (undoes \(names[v])→\(names[u]))")
            v = u
        }
        v = sink
        while v != source {
            residual[parent[v]][v] -= bottleneck
            residual[v][parent[v]] += bottleneck
            v = parent[v]
        }
        total += bottleneck
        print("push \(bottleneck): \(steps.reversed().joined(separator: ", "))")
    }
}

let names = ["S", "A", "C", "D", "E", "T"]
var capacity = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 6)
for (from, to) in [("S", "A"), ("S", "C"), ("A", "D"), ("A", "E"), ("C", "D"), ("D", "T"), ("E", "T")] {
    capacity[names.firstIndex(of: from)!][names.firstIndex(of: to)!] = 1
}
print("max flow:", maxFlow(capacity, from: 0, to: 5, names: names))
