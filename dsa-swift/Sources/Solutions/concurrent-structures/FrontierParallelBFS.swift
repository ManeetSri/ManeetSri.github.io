// Reference solution: Parallel BFS, level by level. Every node in the frontier is at the same
// distance, so the frontier can be processed in any order, or all at once. Each child task gets a
// chunk of the frontier and a read-only view of the distances as they were when the level began, and
// returns the neighbours it saw that were still undiscovered. Nothing is written by a child. The
// parent then walks the returned lists in chunk order, and the first time it meets a node that's
// still undiscovered, it records the distance and adds the node to the next frontier, so a node
// reached from two chunks is only added once. O(V + E) work in total, plus one task-group round per
// level.

public enum FrontierParallelBFS {
    public static func distances(graph: [[Int]], source: Int, chunkSize: Int) async -> [Int] {
        var distance = Array(repeating: -1, count: graph.count)
        distance[source] = 0
        var frontier = [source]
        var level = 0
        while !frontier.isEmpty {
            let candidates = await gatherNeighbours(of: frontier, graph: graph, distance: distance, chunkSize: chunkSize)
            // The children have finished and released their view of `distance`, so these writes don't
            // copy the array
            var next: [Int] = []
            for list in candidates {
                for node in list where distance[node] == -1 {
                    distance[node] = level + 1
                    next.append(node)
                }
            }
            frontier = next
            level += 1
        }
        return distance
    }

    /// For each chunk of the frontier, in order, the neighbours that were undiscovered when the level
    /// began. A node may appear in several lists; the caller keeps the first.
    private static func gatherNeighbours(of frontier: [Int], graph: [[Int]], distance: [Int], chunkSize: Int) async -> [[Int]] {
        let size = max(chunkSize, 1)
        let chunkCount = (frontier.count + size - 1) / size
        return await withTaskGroup(of: (chunk: Int, found: [Int]).self) { group in
            for chunk in 0..<chunkCount {
                let nodes = frontier[(chunk * size)..<min((chunk + 1) * size, frontier.count)]
                group.addTask {
                    var found: [Int] = []
                    for node in nodes {
                        for next in graph[node] where distance[next] == -1 {
                            found.append(next)
                        }
                    }
                    return (chunk, found)
                }
            }
            var byChunk = Array(repeating: [Int](), count: chunkCount)
            for await result in group {
                byChunk[result.chunk] = result.found
            }
            return byChunk
        }
    }
}
