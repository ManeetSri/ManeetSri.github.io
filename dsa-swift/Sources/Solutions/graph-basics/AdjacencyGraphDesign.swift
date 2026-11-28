// Reference solution: Build a generic graph. Each vertex has an adjacency list (an array of the
// vertices it points to, in the order the edges were added) and, beside it, a dictionary of each
// edge's weight, so "is this edge already here?" costs O(1) instead of a scan along the list.
// A separate array keeps the vertices in insertion order, and in-degrees are counted as edges come
// and go. Adding, checking and counting are O(1) on average; removing an edge is O(degree), because
// it's found and taken out of an array.

public enum AdjacencyGraphDesign {
    public struct Graph<Vertex: Hashable> {
        public let isDirected: Bool
        public private(set) var vertices: [Vertex] = []
        public private(set) var edgeCount = 0
        private var targets: [Vertex: [Vertex]] = [:]          // the adjacency lists
        private var weights: [Vertex: [Vertex: Int]] = [:]     // weights[u][v] is the edge u → v
        private var incoming: [Vertex: Int] = [:]              // in-degrees

        public init(directed: Bool) {
            isDirected = directed
        }

        public func contains(_ vertex: Vertex) -> Bool {
            targets[vertex] != nil
        }

        public mutating func addVertex(_ vertex: Vertex) {
            guard targets[vertex] == nil else { return }
            targets[vertex] = []
            weights[vertex] = [:]
            incoming[vertex] = 0
            vertices.append(vertex)
        }

        public mutating func addEdge(from: Vertex, to: Vertex, weight: Int = 1) {
            addVertex(from)
            addVertex(to)
            let isNew = link(from, to, weight)
            if !isDirected && from != to {
                link(to, from, weight)
            }
            if isNew {
                edgeCount += 1
            }
        }

        @discardableResult
        public mutating func removeEdge(from: Vertex, to: Vertex) -> Bool {
            guard unlink(from, to) else { return false }
            if !isDirected && from != to {
                unlink(to, from)
            }
            edgeCount -= 1
            return true
        }

        public func neighbors(of vertex: Vertex) -> [(vertex: Vertex, weight: Int)] {
            guard let list = targets[vertex], let weight = weights[vertex] else { return [] }
            return list.map { (vertex: $0, weight: weight[$0]!) }
        }

        public func outDegree(of vertex: Vertex) -> Int {
            targets[vertex]?.count ?? 0
        }

        public func inDegree(of vertex: Vertex) -> Int {
            incoming[vertex] ?? 0
        }

        /// Records the one-way edge from → to, or replaces its weight. Returns true if it's new.
        @discardableResult
        private mutating func link(_ from: Vertex, _ to: Vertex, _ weight: Int) -> Bool {
            let isNew = weights[from]!.updateValue(weight, forKey: to) == nil
            if isNew {
                targets[from]!.append(to)
                incoming[to]! += 1
            }
            return isNew
        }

        /// Deletes the one-way edge from → to. Returns false if it wasn't there.
        @discardableResult
        private mutating func unlink(_ from: Vertex, _ to: Vertex) -> Bool {
            guard weights[from]?.removeValue(forKey: to) != nil else { return false }
            targets[from]!.remove(at: targets[from]!.firstIndex(of: to)!)
            incoming[to]! -= 1
            return true
        }
    }
}
