// Generated from src/dsa/content/lessons/dp-advanced/dpa-rerooting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Sum of distances from every node to all the others: one pass down, one pass up
func distanceSums(_ n: Int, _ edges: [[Int]]) -> [Int] {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    // Root the tree at 0: parents, and an order with every parent before its children
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

    // Down pass, children first: size of each subtree, and the sum of distances from v into its subtree
    var size = [Int](repeating: 1, count: n)
    var down = [Int](repeating: 0, count: n)
    for v in order.reversed() where parent[v] >= 0 {
        size[parent[v]] += size[v]
        down[parent[v]] += down[v] + size[v]      // every node below v is one step further from the parent
    }
    print("size:", size)
    print("down:", down)

    // Up pass, parents first: move the root from p to its child v
    var answer = [Int](repeating: 0, count: n)
    answer[0] = down[0]
    for v in order where parent[v] >= 0 {
        answer[v] = answer[parent[v]] - size[v] + (n - size[v])
    }
    return answer
}

let edges = [[0, 1], [0, 2], [2, 3], [2, 4], [4, 5], [4, 6]]
print("answer:", distanceSums(7, edges))
