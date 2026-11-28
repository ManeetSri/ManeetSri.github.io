// Generated from src/dsa/content/lessons/advanced-graphs/ag-euler.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Where must an Euler path start in a directed graph, if one exists?
func eulerStart(_ n: Int, _ edges: [[Int]]) -> Int? {
    var outDegree = [Int](repeating: 0, count: n)
    var inDegree = [Int](repeating: 0, count: n)
    for edge in edges {
        outDegree[edge[0]] += 1
        inDegree[edge[1]] += 1
    }
    var starts: [Int] = []
    var ends = 0
    for v in 0..<n {
        switch outDegree[v] - inDegree[v] {
        case 0: continue
        case 1: starts.append(v)
        case -1: ends += 1
        default: return nil                    // too unbalanced for any Euler path
        }
    }
    if starts.isEmpty && ends == 0 {           // balanced: a circuit, so start anywhere with an edge
        return (0..<n).first { outDegree[$0] > 0 } ?? 0
    }
    return starts.count == 1 && ends == 1 ? starts[0] : nil
}

print(eulerStart(4, [[0, 1], [1, 2], [2, 0], [2, 3]]) as Any)
print(eulerStart(3, [[0, 1], [1, 2], [2, 0]]) as Any)
print(eulerStart(3, [[0, 1], [0, 2]]) as Any)
