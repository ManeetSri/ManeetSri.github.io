// A graph stored as adjacency lists (M41 · Build Graph<Vertex: Hashable>).
//
// Each vertex owns a record of its outgoing edges: an array of the vertices it points to, in the
// order the edges were added, beside a dictionary from each of those vertices to the edge's weight.
// The array gives a deterministic iteration order; the dictionary answers "is there an edge from u
// to v, and what does it weigh?" in O(1), which is also how a duplicate edge is spotted without
// scanning the list. A separate array keeps the vertices in insertion order, because a dictionary's
// own order changes from run to run.
//
// Undirected graphs store every edge twice, once in each endpoint's record, so walking from either
// end finds it. A self-loop (an edge from a vertex to itself) is stored once.
//
// Duplicate edges: the graph is simple. There's at most one edge from u to v (in an undirected
// graph, at most one between them), so adding an edge that already exists replaces its weight
// rather than adding a parallel edge. Problems with parallel edges usually only care about the
// cheapest, which you can keep by checking `weight(from:to:)` before adding.
//
// Traversals, topological sort and shortest paths are deliberately not here: you write them in M42
// to M44, on top of `neighbors(of:)`.

/// A directed or undirected graph whose vertices are any `Hashable` values, with `Int` edge weights
/// (1 unless you say otherwise), stored as adjacency lists.
///
/// ```swift
/// var roads = Graph<String>(directed: false)
/// roads.addEdge(from: "Leeds", to: "York", weight: 40)
/// roads.addEdge(from: "Leeds", to: "Hull", weight: 95)
/// roads.vertices                       // ["Leeds", "York", "Hull"]
/// roads.neighbors(of: "Leeds")         // [(vertex: "York", weight: 40), (vertex: "Hull", weight: 95)]
/// roads.degree(of: "Leeds")            // 2
///
/// var steps = Graph<String>(directed: true, edges: [("shop", "cook"), ("cook", "eat")])
/// steps.inDegree(of: "eat")            // 1
/// steps.containsEdge(from: "eat", to: "cook")   // false: edges have a direction
/// ```
///
/// Every list the graph hands back is in insertion order: `vertices` in the order vertices were
/// first added, and `neighbors(of:)` in the order the edges were first added, so the same code always
/// produces the same output. `Graph` is a value type: copying a graph gives an independent graph.
///
/// The policies, in one place:
/// - **Missing vertices** are added by `addEdge(from:to:weight:)`, `from` first.
/// - **Duplicate edges** aren't stored twice: adding an existing edge replaces its weight and keeps
///   its place in the neighbour list.
/// - **Self-loops** are allowed and stored once. In an undirected graph a self-loop adds 1 to the
///   vertex's degree here, because it's one entry in its neighbour list (graph theory books count it
///   twice); in a directed graph it adds 1 to the in-degree and 1 to the out-degree.
/// - **Unknown vertices** are fine to ask about: they have no neighbours and degree 0.
public struct Graph<Vertex: Hashable> {
    /// The outgoing edges of one vertex, and how many edges arrive at it.
    private struct Adjacency {
        /// The vertices this one has an edge to, in the order the edges were first added.
        var targets: [Vertex] = []
        /// The weight of the edge to each vertex in `targets`.
        var weights: [Vertex: Int] = [:]
        /// The number of edges that end at this vertex.
        var incoming = 0
    }

    /// True for a directed graph, where an edge from u to v doesn't let you go from v to u.
    public let isDirected: Bool

    /// Every vertex, in the order each was first added. O(1).
    public private(set) var vertices: [Vertex] = []

    /// The number of edges. An undirected edge counts once, although both endpoints list it. O(1).
    public private(set) var edgeCount = 0

    private var records: [Vertex: Adjacency] = [:]

    /// Creates an empty graph. Pass `directed: true` for one-way edges. O(1).
    public init(directed: Bool) {
        self.isDirected = directed
    }

    /// Creates a graph holding `edges`, each with weight 1, adding vertices in the order they first
    /// appear. O(V + E).
    public init(directed: Bool, edges: [(Vertex, Vertex)]) {
        self.init(directed: directed)
        for (from, to) in edges {
            addEdge(from: from, to: to)
        }
    }

    /// Creates a graph holding `weightedEdges`, each a `(from, to, weight)` triple, adding vertices
    /// in the order they first appear. O(V + E).
    public init(directed: Bool, weightedEdges: [(Vertex, Vertex, Int)]) {
        self.init(directed: directed)
        for (from, to, weight) in weightedEdges {
            addEdge(from: from, to: to, weight: weight)
        }
    }

    // MARK: - Size and membership

    /// The number of vertices. O(1).
    public var vertexCount: Int {
        vertices.count
    }

    /// True when the graph has no vertices (and so no edges). O(1).
    public var isEmpty: Bool {
        vertices.isEmpty
    }

    /// True when `vertex` is in the graph. O(1) on average.
    public func contains(_ vertex: Vertex) -> Bool {
        records[vertex] != nil
    }

    /// True when there's an edge from `from` to `to`. In an undirected graph that's the same as an
    /// edge from `to` to `from`. O(1) on average.
    public func containsEdge(from: Vertex, to: Vertex) -> Bool {
        records[from]?.weights[to] != nil
    }

    /// The weight of the edge from `from` to `to`, or nil if there's no such edge. O(1) on average.
    public func weight(from: Vertex, to: Vertex) -> Int? {
        records[from]?.weights[to]
    }

    // MARK: - Changing the graph

    /// Adds `vertex` with no edges, and returns true. If it's already there, nothing changes and the
    /// result is false. O(1) on average.
    @discardableResult
    public mutating func addVertex(_ vertex: Vertex) -> Bool {
        guard records[vertex] == nil else { return false }
        records[vertex] = Adjacency()
        vertices.append(vertex)
        return true
    }

    /// Adds an edge from `from` to `to` with `weight`, first adding either vertex if it's missing.
    /// In an undirected graph the edge goes both ways. Returns true for a new edge; if the edge was
    /// already there, its weight is replaced and the result is false. O(1) on average.
    @discardableResult
    public mutating func addEdge(from: Vertex, to: Vertex, weight: Int = 1) -> Bool {
        addVertex(from)
        addVertex(to)
        let isNew = link(from, to, weight)
        if !isDirected && from != to {
            link(to, from, weight)
        }
        if isNew {
            edgeCount += 1
        }
        return isNew
    }

    /// Removes the edge from `from` to `to` (in an undirected graph, the edge between them) and
    /// returns true, or returns false if there's no such edge. The vertices stay, and the other
    /// neighbours keep their order. O(out-degree of the endpoints).
    @discardableResult
    public mutating func removeEdge(from: Vertex, to: Vertex) -> Bool {
        guard unlink(from, to) else { return false }
        if !isDirected && from != to {
            unlink(to, from)
        }
        edgeCount -= 1
        return true
    }

    /// Records the one-way edge `from → to`, or updates its weight. Both vertices must exist.
    /// Returns true when the edge is new.
    @discardableResult
    private mutating func link(_ from: Vertex, _ to: Vertex, _ weight: Int) -> Bool {
        let isNew = records[from]!.weights.updateValue(weight, forKey: to) == nil
        if isNew {
            records[from]!.targets.append(to)
            records[to]!.incoming += 1
        }
        return isNew
    }

    /// Deletes the one-way edge `from → to`. Returns false when there was no such edge.
    @discardableResult
    private mutating func unlink(_ from: Vertex, _ to: Vertex) -> Bool {
        guard records[from]?.weights.removeValue(forKey: to) != nil else { return false }
        if let index = records[from]!.targets.firstIndex(of: to) {
            records[from]!.targets.remove(at: index)
        }
        records[to]!.incoming -= 1
        return true
    }

    // MARK: - Reading the edges

    /// The edges leaving `vertex`, as `(vertex, weight)` pairs in the order they were first added.
    /// Empty for a vertex with no edges, or one that isn't in the graph. O(out-degree).
    ///
    /// ```swift
    /// for (next, weight) in graph.neighbors(of: current) { … }
    /// ```
    public func neighbors(of vertex: Vertex) -> [(vertex: Vertex, weight: Int)] {
        guard let record = records[vertex] else { return [] }
        return record.targets.map { (vertex: $0, weight: record.weights[$0]!) }
    }

    /// The vertices `vertex` has an edge to, without weights, in the order the edges were first
    /// added. O(1): it hands back the stored array, which is only copied if you change it.
    public func adjacentVertices(of vertex: Vertex) -> [Vertex] {
        records[vertex]?.targets ?? []
    }

    /// The number of edges leaving `vertex`: the length of its neighbour list. O(1).
    public func outDegree(of vertex: Vertex) -> Int {
        records[vertex]?.targets.count ?? 0
    }

    /// The number of edges arriving at `vertex`. In an undirected graph this equals the out-degree.
    /// O(1), because the graph keeps the count up to date as edges come and go.
    public func inDegree(of vertex: Vertex) -> Int {
        records[vertex]?.incoming ?? 0
    }

    /// The degree of `vertex`. Undirected: the number of neighbours (a self-loop counts once).
    /// Directed: in-degree plus out-degree (a self-loop counts once each way). O(1).
    public func degree(of vertex: Vertex) -> Int {
        isDirected ? inDegree(of: vertex) + outDegree(of: vertex) : outDegree(of: vertex)
    }

    /// Every edge once, as `(from, to, weight)`, grouped by `from` in vertex order and then in
    /// neighbour order. An undirected edge appears once, from whichever endpoint was added first.
    /// This is the graph as an edge list, for algorithms such as Kruskal's. O(V + E).
    public var edges: [(from: Vertex, to: Vertex, weight: Int)] {
        var result: [(from: Vertex, to: Vertex, weight: Int)] = []
        result.reserveCapacity(edgeCount)
        var finished = Set<Vertex>()
        for vertex in vertices {
            let record = records[vertex]!
            for target in record.targets where isDirected || !finished.contains(target) {
                result.append((from: vertex, to: target, weight: record.weights[target]!))
            }
            if !isDirected {
                finished.insert(vertex)
            }
        }
        return result
    }
}

extension Graph: CustomStringConvertible {
    /// A summary line, then one line per vertex listing its neighbours, with a weight in brackets when
    /// it isn't 1. Directed graphs use `->` and undirected ones `--`. O(V + E).
    ///
    /// ```text
    /// Graph(directed, 3 vertices, 2 edges)
    /// shop -> cook, bank(5)
    /// cook -> (none)
    /// bank -> (none)
    /// ```
    public var description: String {
        let arrow = isDirected ? "->" : "--"
        let counts = "\(vertexCount) \(vertexCount == 1 ? "vertex" : "vertices"), \(edgeCount) \(edgeCount == 1 ? "edge" : "edges")"
        var lines = ["Graph(\(isDirected ? "directed" : "undirected"), \(counts))"]
        for vertex in vertices {
            let listed = neighbors(of: vertex).map { $0.weight == 1 ? "\($0.vertex)" : "\($0.vertex)(\($0.weight))" }
            lines.append("\(vertex) \(arrow) \(listed.isEmpty ? "(none)" : listed.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }
}
