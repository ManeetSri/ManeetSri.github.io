// Problem: Build a generic graph (M41 · Build Graph<Vertex: Hashable>)

public enum AdjacencyGraphDesign {
    /// A directed or undirected graph stored as adjacency lists, with Int weights (1 by default).
    /// `vertices` and `neighbors(of:)` list things in the order they were first added. There's at most
    /// one edge from a vertex to another: adding it again replaces its weight. A self-loop is stored
    /// once. Asking about a vertex that isn't there gives no neighbours and degree 0.
    public struct Graph<Vertex: Hashable> {
        // Write your solution here, then run:
        // swift test --filter AdjacencyGraphDesignTests
        // Add your storage as private properties. Dictionaries keyed by Vertex are a good start.

        /// True when edges are one-way.
        public let isDirected: Bool

        /// Creates an empty graph. O(1).
        public init(directed: Bool) {
            isDirected = directed
        }

        /// Every vertex, in the order each was first added.
        public var vertices: [Vertex] {
            return []
        }

        /// The number of edges. An undirected edge counts once.
        public var edgeCount: Int {
            return 0
        }

        /// True when `vertex` is in the graph. Aim for O(1).
        public func contains(_ vertex: Vertex) -> Bool {
            return false
        }

        /// Adds `vertex` with no edges, unless it's already there.
        public mutating func addVertex(_ vertex: Vertex) {
        }

        /// Adds the edge from `from` to `to` (both ways when undirected), adding missing vertices
        /// first, `from` before `to`. If the edge exists, only its weight changes. Aim for O(1).
        public mutating func addEdge(from: Vertex, to: Vertex, weight: Int = 1) {
        }

        /// Removes the edge from `from` to `to` (both ways when undirected) and returns true, or
        /// returns false if there's no such edge. The vertices stay.
        @discardableResult
        public mutating func removeEdge(from: Vertex, to: Vertex) -> Bool {
            return false
        }

        /// The edges leaving `vertex`, in the order they were first added.
        public func neighbors(of vertex: Vertex) -> [(vertex: Vertex, weight: Int)] {
            return []
        }

        /// The number of edges leaving `vertex`. Aim for O(1).
        public func outDegree(of vertex: Vertex) -> Int {
            return 0
        }

        /// The number of edges arriving at `vertex`. Aim for O(1).
        public func inDegree(of vertex: Vertex) -> Int {
            return 0
        }
    }
}
