// Generated from src/dsa/content/lessons/dp-advanced/dpa-dags.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Kahn's algorithm: an order where every edge goes forwards (the graph must be a DAG)
func topologicalOrder(_ n: Int, _ edges: [[Int]]) -> [Int] {
    var outgoing = [[Int]](repeating: [], count: n)
    var inDegree = [Int](repeating: 0, count: n)
    for edge in edges {
        outgoing[edge[0]].append(edge[1])
        inDegree[edge[1]] += 1
    }
    var order = (0..<n).filter { inDegree[$0] == 0 }
    var head = 0
    while head < order.count {
        let v = order[head]
        head += 1
        for w in outgoing[v] {
            inDegree[w] -= 1
            if inDegree[w] == 0 { order.append(w) }
        }
    }
    return order
}

// Two DPs over the same order: the number of paths from source, and the longest path from source
func pathFacts(_ n: Int, _ edges: [[Int]], from source: Int) -> (ways: [Int], longest: [Int]) {
    var incoming = [[(from: Int, length: Int)]](repeating: [], count: n)
    for edge in edges {
        incoming[edge[1]].append((edge[0], edge.count > 2 ? edge[2] : 1))
    }
    var ways = [Int](repeating: 0, count: n)
    var longest = [Int](repeating: -1, count: n)      // -1: not reachable from source
    ways[source] = 1
    longest[source] = 0
    for v in topologicalOrder(n, edges) {
        for (u, length) in incoming[v] where longest[u] >= 0 {   // u comes earlier, so it is final
            ways[v] += ways[u]
            longest[v] = max(longest[v], longest[u] + length)
        }
    }
    return (ways, longest)
}

let edges = [[0, 1, 3], [0, 2, 2], [1, 3, 4], [2, 3, 1], [2, 4, 6], [3, 5, 2], [4, 5, 1], [1, 5, 9], [6, 4, 1]]
print("order:", topologicalOrder(7, edges))
let facts = pathFacts(7, edges, from: 0)
print("ways:", facts.ways)
print("longest:", facts.longest)

// Climbing 10 stairs, one or two at a time, is counting paths in a DAG too
var stairs: [[Int]] = []
for step in 0..<10 {
    stairs.append([step, step + 1])                   // one stair
    if step + 2 <= 10 { stairs.append([step, step + 2]) }   // two stairs
}
print("stairs:", pathFacts(11, stairs, from: 0).ways[10])
