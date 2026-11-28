// Problem: Parallel BFS, level by level (M70 · Parallel merge sort and BFS with TaskGroup)

public enum FrontierParallelBFS {
    /// The number of edges on a shortest path from `source` to every node of a directed graph, where
    /// `graph[v]` lists the nodes that `v` has edges to; -1 for nodes `source` can't reach.
    /// Work level by level: split each level's frontier into chunks of at most `chunkSize` nodes, and
    /// gather each chunk's undiscovered neighbours in its own child task of a task group.
    /// `chunkSize` is at least 1.
    public static func distances(graph: [[Int]], source: Int, chunkSize: Int) async -> [Int] {
        // Write your solution here, then run:
        // swift test --filter FrontierParallelBFSTests
        return []
    }
}
