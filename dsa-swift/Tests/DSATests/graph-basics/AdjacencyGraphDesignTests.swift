import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AdjacencyGraphDesignTests {
    typealias Graph<Vertex: Hashable> = AdjacencyGraphDesign.Graph<Vertex>

    /// The neighbours of `vertex` as "name:weight" strings, which compare easily.
    private func listed<V>(_ graph: Graph<V>, _ vertex: V) -> [String] {
        graph.neighbors(of: vertex).map { "\($0.vertex):\($0.weight)" }
    }

    @Test("A new graph is empty")
    func empty() {
        var graph = Graph<String>(directed: true)
        #expect(graph.isDirected)
        #expect(!Graph<Int>(directed: false).isDirected)
        #expect(graph.vertices == [])
        #expect(graph.edgeCount == 0)
        #expect(!graph.contains("a"))
        #expect(graph.neighbors(of: "a").isEmpty)
        #expect(graph.outDegree(of: "a") == 0)
        #expect(graph.inDegree(of: "a") == 0)
        let removed = graph.removeEdge(from: "a", to: "b")
        #expect(removed == false)
    }

    @Test("Vertices are kept in insertion order, each once")
    func vertexOrder() {
        var graph = Graph<String>(directed: false)
        graph.addVertex("m")
        graph.addEdge(from: "c", to: "m")
        graph.addVertex("c")
        graph.addEdge(from: "a", to: "z")
        graph.addVertex("q")
        #expect(graph.vertices == ["m", "c", "a", "z", "q"])
        #expect(graph.contains("q") && graph.contains("z") && !graph.contains("b"))
        #expect(graph.neighbors(of: "q").isEmpty)
    }

    @Test("Directed edges go one way")
    func directed() {
        var graph = Graph<String>(directed: true)
        graph.addEdge(from: "shirt", to: "tie")
        graph.addEdge(from: "shirt", to: "belt")
        graph.addEdge(from: "trousers", to: "belt")
        graph.addEdge(from: "tie", to: "jacket")
        graph.addEdge(from: "belt", to: "jacket")
        #expect(graph.vertices == ["shirt", "tie", "belt", "trousers", "jacket"])
        #expect(graph.edgeCount == 5)
        #expect(listed(graph, "shirt") == ["tie:1", "belt:1"])
        #expect(listed(graph, "jacket") == [])
        #expect(graph.outDegree(of: "shirt") == 2)
        #expect(graph.inDegree(of: "shirt") == 0)
        #expect(graph.inDegree(of: "belt") == 2)
        #expect(graph.inDegree(of: "jacket") == 2)
        #expect(graph.outDegree(of: "jacket") == 0)
    }

    @Test("Undirected edges appear at both ends and count once")
    func undirected() {
        var graph = Graph<Int>(directed: false)
        graph.addEdge(from: 1, to: 2, weight: 7)
        graph.addEdge(from: 3, to: 1, weight: 4)
        graph.addEdge(from: 2, to: 3)
        #expect(graph.edgeCount == 3)
        #expect(listed(graph, 1) == ["2:7", "3:4"])
        #expect(listed(graph, 2) == ["1:7", "3:1"])
        #expect(listed(graph, 3) == ["1:4", "2:1"])
        for vertex in [1, 2, 3] {
            #expect(graph.outDegree(of: vertex) == 2)
            #expect(graph.inDegree(of: vertex) == 2)
        }
    }

    @Test("Adding an existing edge replaces its weight")
    func duplicates() {
        var directed = Graph<String>(directed: true)
        directed.addEdge(from: "a", to: "b", weight: 5)
        directed.addEdge(from: "a", to: "c")
        directed.addEdge(from: "a", to: "b", weight: 9)
        #expect(listed(directed, "a") == ["b:9", "c:1"])
        #expect(directed.edgeCount == 2)
        #expect(directed.inDegree(of: "b") == 1)
        directed.addEdge(from: "b", to: "a")                 // the reverse is a different edge
        #expect(directed.edgeCount == 3)

        var undirected = Graph<String>(directed: false)
        undirected.addEdge(from: "a", to: "b", weight: 5)
        undirected.addEdge(from: "b", to: "a", weight: 2)    // the same edge, from the other end
        #expect(undirected.edgeCount == 1)
        #expect(listed(undirected, "a") == ["b:2"])
        #expect(listed(undirected, "b") == ["a:2"])
        #expect(undirected.outDegree(of: "a") == 1)
    }

    @Test("Self-loops are stored once")
    func selfLoops() {
        var undirected = Graph<Int>(directed: false)
        undirected.addEdge(from: 4, to: 4, weight: 3)
        undirected.addEdge(from: 4, to: 5)
        #expect(undirected.vertices == [4, 5])
        #expect(undirected.edgeCount == 2)
        #expect(listed(undirected, 4) == ["4:3", "5:1"])
        #expect(undirected.outDegree(of: 4) == 2)
        let removed = undirected.removeEdge(from: 4, to: 4)
        #expect(removed)
        #expect(listed(undirected, 4) == ["5:1"])
        #expect(undirected.edgeCount == 1)

        var directed = Graph<Int>(directed: true)
        directed.addEdge(from: 9, to: 9)
        #expect(directed.outDegree(of: 9) == 1)
        #expect(directed.inDegree(of: 9) == 1)
        #expect(directed.edgeCount == 1)
    }

    @Test("Removing edges")
    func removal() {
        var directed = Graph<Int>(directed: true)
        for (from, to) in [(0, 1), (0, 2), (0, 3), (2, 3)] {
            directed.addEdge(from: from, to: to)
        }
        var removed = directed.removeEdge(from: 0, to: 2)
        #expect(removed)
        #expect(listed(directed, 0) == ["1:1", "3:1"])
        #expect(directed.inDegree(of: 2) == 0)
        #expect(directed.edgeCount == 3)
        removed = directed.removeEdge(from: 0, to: 2)
        #expect(!removed)
        removed = directed.removeEdge(from: 3, to: 2)
        #expect(!removed)
        removed = directed.removeEdge(from: 3, to: 0)      // edges have a direction
        #expect(!removed)
        removed = directed.removeEdge(from: 8, to: 9)
        #expect(!removed)
        #expect(directed.edgeCount == 3)
        #expect(directed.vertices == [0, 1, 2, 3])          // the vertices stay
        directed.addEdge(from: 0, to: 2)
        #expect(listed(directed, 0) == ["1:1", "3:1", "2:1"])

        var undirected = Graph<Int>(directed: false)
        for (from, to) in [(0, 1), (1, 2), (2, 0)] {
            undirected.addEdge(from: from, to: to)
        }
        removed = undirected.removeEdge(from: 2, to: 1)
        #expect(removed)
        #expect(listed(undirected, 1) == ["0:1"])
        #expect(listed(undirected, 2) == ["0:1"])
        #expect(undirected.edgeCount == 2)
        #expect(undirected.inDegree(of: 1) == 1)
        removed = undirected.removeEdge(from: 1, to: 2)
        #expect(!removed)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = Graph<String>(directed: false)
        original.addEdge(from: "x", to: "y")
        var copy = original
        copy.addEdge(from: "y", to: "z")
        copy.removeEdge(from: "x", to: "y")
        #expect(original.vertices == ["x", "y"])
        #expect(listed(original, "x") == ["y:1"])
        #expect(original.edgeCount == 1)
        #expect(copy.vertices == ["x", "y", "z"])
        #expect(listed(copy, "x") == [])
    }

    @Test("Works with any Hashable vertex type")
    func otherVertexTypes() {
        struct Cell: Hashable {
            let row: Int
            let column: Int
        }
        var grid = Graph<Cell>(directed: false)
        grid.addEdge(from: Cell(row: 0, column: 0), to: Cell(row: 0, column: 1))
        grid.addEdge(from: Cell(row: 0, column: 0), to: Cell(row: 1, column: 0))
        #expect(grid.outDegree(of: Cell(row: 0, column: 0)) == 2)
        #expect(grid.neighbors(of: Cell(row: 1, column: 0)).map(\.vertex) == [Cell(row: 0, column: 0)])
    }

    @Test("100,000 edges at one vertex, then all of them again")
    func bigHub() {
        var graph = Graph<Int>(directed: true)
        for leaf in 1...100_000 {
            graph.addEdge(from: 0, to: leaf)
            graph.addEdge(from: leaf, to: 0, weight: leaf)
        }
        // Each repeat must find the existing edge quickly, not by walking a 100,000-entry list
        for leaf in 1...100_000 {
            graph.addEdge(from: 0, to: leaf, weight: 2)
        }
        #expect(graph.vertices.count == 100_001)
        #expect(graph.edgeCount == 200_000)
        #expect(graph.outDegree(of: 0) == 100_000)
        #expect(graph.inDegree(of: 0) == 100_000)
        let fromHub = graph.neighbors(of: 0)
        #expect(fromHub.count == 100_000)
        #expect(fromHub.first?.vertex == 1 && fromHub.first?.weight == 2)
        #expect(fromHub.last?.vertex == 100_000)
        #expect(graph.neighbors(of: 54_321).map(\.weight) == [54_321])
    }
}
