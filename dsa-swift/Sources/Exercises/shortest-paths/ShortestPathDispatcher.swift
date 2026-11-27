// Problem: Pick the right shortest-path algorithm (M44 · Choosing a shortest-path algorithm)

import DSAKit

public enum ShortestPathDispatcher {
    /// The algorithms to choose from, in the order the decision table tries them.
    public enum Method: Sendable, CaseIterable {
        /// There are no edges, or every edge has the same weight, at least 1.
        case bfs
        /// Every weight is 0 or 1.
        case zeroOneBFS
        /// The graph has no directed cycle (a loop from a node to itself counts as a cycle).
        case dagOrder
        /// Every weight is at least 0.
        case dijkstra
        /// Anything else: some weights are negative and there's a cycle, but never a negative cycle.
        case bellmanFord
    }

    /// Nodes are numbered 0..<nodes, and each edge [from, to, weight] goes one way. Returns the first
    /// method in `Method` whose condition the graph meets, and the shortest distance from `source` to
    /// every node (nil if unreachable), computed with that method.
    public static func route(nodes: Int, edges: [[Int]], source: Int) -> (method: Method, distances: [Int?]) {
        // Write your solution here, then run:
        // swift test --filter ShortestPathDispatcherTests
        // DSAKit's Heap and Deque are imported, if you want them.
        return (.bellmanFord, [])
    }
}
