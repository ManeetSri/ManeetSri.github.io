// Generated from src/dsa/content/lessons/dp-advanced/dpa-rerooting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Distance to the farthest node, for every node: max isn't reversible, so keep the top two
func farthest(_ n: Int, _ edges: [[Int]]) -> [Int] {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var parent = [Int](repeating: -1, count: n)
    var order = [0]
    var head = 0
    while head < order.count {
        let v = order[head]
        head += 1
        for w in neighbours[v] where w != parent[v] {
            parent[w] = v
            order.append(w)
        }
    }

    // Down pass: the longest and second-longest paths down, through different children
    var first = [Int](repeating: 0, count: n)
    var second = [Int](repeating: 0, count: n)
    var firstChild = [Int](repeating: -1, count: n)     // which child the longest one goes through
    for v in order.reversed() where parent[v] >= 0 {
        let p = parent[v], path = first[v] + 1
        if path > first[p] {
            second[p] = first[p]
            first[p] = path
            firstChild[p] = v
        } else if path > second[p] {
            second[p] = path
        }
    }

    // Up pass: up[v] is the longest path that starts at v and leaves through its parent
    var up = [Int](repeating: 0, count: n)
    for v in order where parent[v] >= 0 {
        let p = parent[v]
        let bestDownAvoidingV = firstChild[p] == v ? second[p] : first[p]
        up[v] = 1 + max(up[p], bestDownAvoidingV)
    }
    return (0..<n).map { max(first[$0], up[$0]) }
}

print(farthest(7, [[0, 1], [0, 2], [2, 3], [2, 4], [4, 5], [4, 6]]))
