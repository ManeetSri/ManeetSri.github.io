// Generated from src/dsa/content/lessons/graph-traversals/gt-bipartite.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// For a connected graph that isn't bipartite, an odd cycle that proves it; nil if it is bipartite
func oddCycle(_ vertexCount: Int, _ edges: [[Int]]) -> [Int]? {
    var neighbours = Array(repeating: [Int](), count: vertexCount)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var depth = Array(repeating: -1, count: vertexCount)
    var parent = Array(repeating: -1, count: vertexCount)
    depth[0] = 0
    var queue = [0]
    var head = 0
    while head < queue.count {
        let vertex = queue[head]
        head += 1
        for next in neighbours[vertex] {
            if depth[next] == -1 {
                depth[next] = depth[vertex] + 1
                parent[next] = vertex
                queue.append(next)
            } else if depth[next] == depth[vertex] {
                // Same depth, so same colour. Climb from both ends until the paths join.
                var left = [vertex]
                var right = [next]
                while left[left.count - 1] != right[right.count - 1] {
                    left.append(parent[left[left.count - 1]])
                    right.append(parent[right[right.count - 1]])
                }
                return left + right.dropLast().reversed()
            }
        }
    }
    return nil
}

print(oddCycle(5, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]]) ?? [])
print(oddCycle(4, [[0, 1], [1, 2], [2, 3], [3, 0], [0, 2]]) ?? [])
print(oddCycle(7, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 0]]) ?? [])
print(oddCycle(4, [[0, 1], [1, 2], [2, 3], [3, 0]]) ?? [])
