// Generated from src/dsa/content/lessons/dp-advanced/dpa-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Tree DP without recursion: list the nodes parents-first, then fill the table in reverse
func largestIndependentSet(_ n: Int, _ edges: [[Int]]) -> Int {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    // 1. A DFS with an explicit stack records each node's parent and an order where parents come first
    var parent = [Int](repeating: -1, count: n)
    var order: [Int] = []
    var stack = [0]
    var seen = [Bool](repeating: false, count: n)
    seen[0] = true
    while let v = stack.popLast() {
        order.append(v)
        for w in neighbours[v] where !seen[w] {
            seen[w] = true
            parent[w] = v
            stack.append(w)
        }
    }
    // 2. Reversed, that order puts every child before its parent: exactly what post-order guarantees
    var with = [Int](repeating: 1, count: n)
    var without = [Int](repeating: 0, count: n)
    for v in order.reversed() {
        let p = parent[v]
        if p >= 0 {                                   // hand v's finished answer up to its parent
            with[p] += without[v]
            without[p] += max(with[v], without[v])
        }
    }
    return max(with[0], without[0])
}

print(largestIndependentSet(8, [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5], [5, 6], [5, 7]]))
let chain = (1..<200_000).map { [$0 - 1, $0] }
print(largestIndependentSet(200_000, chain))
let star = (1..<200_000).map { [0, $0] }
print(largestIndependentSet(200_000, star))
