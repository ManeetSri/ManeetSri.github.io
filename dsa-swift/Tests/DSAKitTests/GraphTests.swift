import Testing
import DSAKit

@Suite struct GraphTests {
    /// A tiny deterministic generator, so the mixed-operation tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The neighbours of `vertex` as "name:weight" strings, which compare easily.
    private func listed<V>(_ graph: Graph<V>, _ vertex: V) -> [String] {
        graph.neighbors(of: vertex).map { "\($0.vertex):\($0.weight)" }
    }

    @Test("A new graph is empty")
    func startsEmpty() {
        var removed: Bool
        var graph = Graph<String>(directed: true)
        #expect(graph.isDirected)
        #expect(graph.isEmpty)
        #expect(graph.vertices == [])
        #expect(graph.vertexCount == 0)
        #expect(graph.edgeCount == 0)
        #expect(graph.edges.isEmpty)
        #expect(!graph.contains("a"))
        #expect(graph.neighbors(of: "a").isEmpty)
        #expect(graph.adjacentVertices(of: "a") == [])
        #expect(graph.degree(of: "a") == 0)
        #expect(graph.inDegree(of: "a") == 0)
        #expect(graph.outDegree(of: "a") == 0)
        #expect(graph.weight(from: "a", to: "b") == nil)
        removed = graph.removeEdge(from: "a", to: "b")
        #expect(removed == false)
        #expect(graph.description == "Graph(directed, 0 vertices, 0 edges)")
        #expect(!Graph<Int>(directed: false).isDirected)
    }

    @Test("Vertices without edges")
    func lonelyVertices() {
        var added: Bool
        var graph = Graph<Int>(directed: false)
        added = graph.addVertex(7)
        #expect(added == true)
        added = graph.addVertex(3)
        #expect(added == true)
        added = graph.addVertex(7)
        #expect(added == false)
        #expect(graph.vertices == [7, 3])
        #expect(graph.contains(7) && graph.contains(3) && !graph.contains(5))
        #expect(graph.edgeCount == 0)
        #expect(graph.degree(of: 7) == 0)
        #expect(graph.neighbors(of: 7).isEmpty)
        #expect(graph.description == "Graph(undirected, 2 vertices, 0 edges)\n7 -- (none)\n3 -- (none)")
    }

    @Test("Directed edges go one way")
    func directed() {
        var added: Bool
        var graph = Graph<String>(directed: true)
        added = graph.addEdge(from: "shirt", to: "tie")
        #expect(added == true)
        graph.addEdge(from: "shirt", to: "belt")
        graph.addEdge(from: "trousers", to: "belt")
        graph.addEdge(from: "tie", to: "jacket")
        #expect(graph.vertices == ["shirt", "tie", "belt", "trousers", "jacket"])
        #expect(graph.edgeCount == 4)
        #expect(graph.adjacentVertices(of: "shirt") == ["tie", "belt"])
        #expect(graph.adjacentVertices(of: "belt") == [])
        #expect(graph.containsEdge(from: "shirt", to: "tie"))
        #expect(!graph.containsEdge(from: "tie", to: "shirt"))
        #expect(graph.outDegree(of: "shirt") == 2)
        #expect(graph.inDegree(of: "shirt") == 0)
        #expect(graph.inDegree(of: "belt") == 2)
        #expect(graph.outDegree(of: "belt") == 0)
        #expect(graph.degree(of: "belt") == 2)
        #expect(graph.degree(of: "tie") == 2)
    }

    @Test("Undirected edges are stored at both ends and counted once")
    func undirected() {
        var graph = Graph<String>(directed: false)
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "A", to: "C")
        graph.addEdge(from: "C", to: "B")
        #expect(graph.vertices == ["A", "B", "C"])
        #expect(graph.edgeCount == 3)
        #expect(graph.adjacentVertices(of: "A") == ["B", "C"])
        #expect(graph.adjacentVertices(of: "B") == ["A", "C"])
        #expect(graph.adjacentVertices(of: "C") == ["A", "B"])
        #expect(graph.containsEdge(from: "B", to: "A"))
        for vertex in ["A", "B", "C"] {
            #expect(graph.degree(of: vertex) == 2)
            #expect(graph.inDegree(of: vertex) == 2)
            #expect(graph.outDegree(of: vertex) == 2)
        }
    }

    @Test("Weights default to 1 and can be read back")
    func weights() {
        var graph = Graph<String>(directed: false)
        graph.addEdge(from: "Leeds", to: "York", weight: 40)
        graph.addEdge(from: "Leeds", to: "Hull", weight: 95)
        graph.addEdge(from: "York", to: "Hull")
        graph.addEdge(from: "Hull", to: "Grimsby", weight: -3)
        #expect(listed(graph, "Leeds") == ["York:40", "Hull:95"])
        #expect(listed(graph, "Hull") == ["Leeds:95", "York:1", "Grimsby:-3"])
        #expect(graph.weight(from: "York", to: "Leeds") == 40)
        #expect(graph.weight(from: "Hull", to: "York") == 1)
        #expect(graph.weight(from: "Leeds", to: "Grimsby") == nil)
        let first = graph.neighbors(of: "Leeds")[0]
        #expect(first.vertex == "York" && first.weight == 40)
    }

    @Test("A duplicate edge replaces the weight and keeps its place")
    func duplicates() {
        var added: Bool
        var directed = Graph<Int>(directed: true)
        directed.addEdge(from: 1, to: 2, weight: 5)
        directed.addEdge(from: 1, to: 3)
        added = directed.addEdge(from: 1, to: 2, weight: 9)
        #expect(added == false)
        #expect(listed(directed, 1) == ["2:9", "3:1"])
        #expect(directed.edgeCount == 2)
        #expect(directed.inDegree(of: 2) == 1)
        // The reverse edge is a different edge in a directed graph
        added = directed.addEdge(from: 2, to: 1)
        #expect(added == true)
        #expect(directed.edgeCount == 3)

        var undirected = Graph<Int>(directed: false)
        undirected.addEdge(from: 1, to: 2, weight: 5)
        added = undirected.addEdge(from: 2, to: 1, weight: 7)
        #expect(added == false)
        #expect(undirected.edgeCount == 1)
        #expect(listed(undirected, 1) == ["2:7"])
        #expect(listed(undirected, 2) == ["1:7"])
        #expect(undirected.degree(of: 1) == 1)
    }

    @Test("Self-loops are stored once")
    func selfLoops() {
        var added: Bool
        var removed: Bool
        var undirected = Graph<String>(directed: false)
        added = undirected.addEdge(from: "a", to: "a", weight: 2)
        #expect(added == true)
        undirected.addEdge(from: "a", to: "b")
        #expect(undirected.vertices == ["a", "b"])
        #expect(undirected.edgeCount == 2)
        #expect(listed(undirected, "a") == ["a:2", "b:1"])
        #expect(undirected.degree(of: "a") == 2)
        #expect(undirected.inDegree(of: "a") == 2)
        added = undirected.addEdge(from: "a", to: "a")
        #expect(added == false)
        #expect(undirected.edgeCount == 2)
        #expect(undirected.edges.map { "\($0.from)\($0.to)" } == ["aa", "ab"])
        removed = undirected.removeEdge(from: "a", to: "a")
        #expect(removed)
        #expect(undirected.adjacentVertices(of: "a") == ["b"])
        #expect(undirected.edgeCount == 1)

        var directed = Graph<String>(directed: true)
        directed.addEdge(from: "x", to: "x")
        #expect(directed.inDegree(of: "x") == 1)
        #expect(directed.outDegree(of: "x") == 1)
        #expect(directed.degree(of: "x") == 2)
        #expect(directed.edgeCount == 1)
        removed = directed.removeEdge(from: "x", to: "x")
        #expect(removed)
        #expect(directed.degree(of: "x") == 0)
        #expect(directed.contains("x"))
    }

    @Test("Removing edges")
    func removal() {
        var removed: Bool
        var directed = Graph<Int>(directed: true, edges: [(0, 1), (0, 2), (0, 3), (2, 3)])
        removed = directed.removeEdge(from: 0, to: 2)
        #expect(removed == true)
        #expect(directed.adjacentVertices(of: 0) == [1, 3])
        #expect(directed.inDegree(of: 2) == 0)
        #expect(directed.edgeCount == 3)
        removed = directed.removeEdge(from: 0, to: 2)
        #expect(removed == false)
        removed = directed.removeEdge(from: 3, to: 2)
        #expect(removed == false)
        removed = directed.removeEdge(from: 9, to: 0)
        #expect(removed == false)
        removed = directed.removeEdge(from: 3, to: 0)
        #expect(removed == false)
        #expect(directed.edgeCount == 3)
        #expect(directed.vertices == [0, 1, 2, 3])
        // Adding it back puts it at the end of the list
        directed.addEdge(from: 0, to: 2)
        #expect(directed.adjacentVertices(of: 0) == [1, 3, 2])

        var undirected = Graph<Int>(directed: false, edges: [(0, 1), (1, 2), (2, 0)])
        removed = undirected.removeEdge(from: 2, to: 1)
        #expect(removed == true)
        #expect(undirected.adjacentVertices(of: 1) == [0])
        #expect(undirected.adjacentVertices(of: 2) == [0])
        #expect(!undirected.containsEdge(from: 1, to: 2))
        #expect(undirected.edgeCount == 2)
        #expect(undirected.degree(of: 2) == 1)
        removed = undirected.removeEdge(from: 1, to: 2)
        #expect(removed == false)
    }

    @Test("Vertices keep their insertion order")
    func deterministicOrder() {
        var graph = Graph<String>(directed: true)
        let names = (0..<2_000).map { "v\(($0 * 7_919) % 2_000)" }
        for (index, name) in names.enumerated() {
            if index.isMultiple(of: 2) {
                graph.addVertex(name)
            } else {
                graph.addEdge(from: name, to: names[0])
            }
        }
        #expect(graph.vertices == names)
        #expect(graph.inDegree(of: names[0]) == 1_000)
        #expect(graph.adjacentVertices(of: names[1]) == [names[0]])
        // Building the same graph again gives exactly the same lists
        var again = Graph<String>(directed: true)
        for (index, name) in names.enumerated() {
            if index.isMultiple(of: 2) { again.addVertex(name) } else { again.addEdge(from: name, to: names[0]) }
        }
        #expect(again.description == graph.description)
    }

    @Test("Edges lists every edge once")
    func edgeList() {
        let directed = Graph<String>(directed: true, weightedEdges: [("a", "b", 3), ("b", "a", 4), ("a", "c", 1)])
        #expect(directed.edges.map { "\($0.from)\($0.to)\($0.weight)" } == ["ab3", "ac1", "ba4"])
        let undirected = Graph<String>(directed: false, weightedEdges: [("c", "a", 2), ("a", "b", 5), ("b", "c", 1)])
        #expect(undirected.vertices == ["c", "a", "b"])
        #expect(undirected.edges.map { "\($0.from)\($0.to)\($0.weight)" } == ["ca2", "cb1", "ab5"])
        #expect(undirected.edges.count == undirected.edgeCount)
    }

    @Test("Description lists each vertex's neighbours")
    func description() {
        var directed = Graph<String>(directed: true)
        directed.addEdge(from: "shop", to: "cook")
        directed.addEdge(from: "shop", to: "bank", weight: 5)
        #expect(directed.description == "Graph(directed, 3 vertices, 2 edges)\nshop -> cook, bank(5)\ncook -> (none)\nbank -> (none)")
        let undirected = Graph<Int>(directed: false, edges: [(1, 2)])
        #expect(undirected.description == "Graph(undirected, 2 vertices, 1 edge)\n1 -- 2\n2 -- 1")
    }

    @Test("Graphs are values")
    func valueSemantics() {
        var original = Graph<Int>(directed: false, edges: [(1, 2)])
        var copy = original
        copy.addEdge(from: 2, to: 3)
        copy.removeEdge(from: 1, to: 2)
        #expect(original.vertices == [1, 2])
        #expect(Graph<Int>(directed: true, edges: [(5, 5)]).description == "Graph(directed, 1 vertex, 1 edge)\n5 -> 5")
        #expect(original.containsEdge(from: 1, to: 2))
        #expect(original.edgeCount == 1)
        #expect(copy.vertices == [1, 2, 3])
        #expect(!copy.containsEdge(from: 1, to: 2))
        original.addVertex(9)
        #expect(!copy.contains(9))
    }

    @Test("Matches a simple model over 20,000 random operations", arguments: [false, true])
    func model(directed: Bool) {
        var added: Bool
        var removed: Bool
        var graph = Graph<Int>(directed: directed)
        var weights: [Int: [Int: Int]] = [:]      // the model: from → to → weight
        var order: [Int] = []
        var steps = Steps(seed: directed ? 41 : 43)
        func modelAdd(_ from: Int, _ to: Int, _ weight: Int) {
            for vertex in [from, to] where weights[vertex] == nil {
                weights[vertex] = [:]
                order.append(vertex)
            }
            weights[from]![to] = weight
            if !directed { weights[to]![from] = weight }
        }
        for _ in 0..<20_000 {
            let from = steps.next(below: 60)
            let to = steps.next(below: 60)
            switch steps.next(below: 10) {
            case 0..<6:
                let weight = steps.next(below: 20) - 5
                let isNew = weights[from]?[to] == nil
                added = graph.addEdge(from: from, to: to, weight: weight)
                #expect(added == isNew)
                modelAdd(from, to, weight)
            case 6..<9:
                let exists = weights[from]?[to] != nil
                removed = graph.removeEdge(from: from, to: to)
                #expect(removed == exists)
                weights[from]?[to] = nil
                if !directed { weights[to]?[from] = nil }
            default:
                if weights[from] == nil { order.append(from); weights[from] = [:] }
                graph.addVertex(from)
            }
        }
        #expect(graph.vertices == order)
        var edgeEnds = 0
        for vertex in order {
            let model = weights[vertex]!
            let neighbours = graph.neighbors(of: vertex)
            #expect(neighbours.count == model.count)
            #expect(Set(neighbours.map(\.vertex)) == Set(model.keys))
            #expect(neighbours.allSatisfy { model[$0.vertex] == $0.weight })
            let incoming = order.filter { weights[$0]![vertex] != nil }.count
            #expect(graph.inDegree(of: vertex) == incoming)
            edgeEnds += model.count
        }
        let loops = order.filter { weights[$0]![$0] != nil }.count
        #expect(graph.edgeCount == (directed ? edgeEnds : (edgeEnds + loops) / 2))
        #expect(graph.edges.count == graph.edgeCount)
    }

    @Test("100,000 edges into and out of one vertex stay fast")
    func bigHub() {
        var graph = Graph<Int>(directed: true)
        for leaf in 1...100_000 {
            graph.addEdge(from: 0, to: leaf)
            graph.addEdge(from: leaf, to: 0, weight: leaf)
        }
        // Adding them all again only replaces weights: each check is a dictionary lookup
        for leaf in 1...100_000 {
            graph.addEdge(from: 0, to: leaf, weight: 2)
        }
        #expect(graph.vertexCount == 100_001)
        #expect(graph.edgeCount == 200_000)
        #expect(graph.outDegree(of: 0) == 100_000)
        #expect(graph.inDegree(of: 0) == 100_000)
        #expect(graph.weight(from: 0, to: 99_999) == 2)
        #expect(graph.weight(from: 99_999, to: 0) == 99_999)
        #expect(graph.adjacentVertices(of: 0).last == 100_000)
    }
}
