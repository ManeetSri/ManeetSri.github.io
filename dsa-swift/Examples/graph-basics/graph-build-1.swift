// Generated from src/dsa/content/lessons/graph-basics/graph-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Graph<Vertex: Hashable> {
    let isDirected: Bool
    private(set) var vertices: [Vertex] = []           // every vertex, in insertion order
    private(set) var edgeCount = 0
    private var targets: [Vertex: [Vertex]] = [:]      // the adjacency lists
    private var weights: [Vertex: [Vertex: Int]] = [:] // weights[u][v] is the edge u → v
    private var incoming: [Vertex: Int] = [:]          // in-degrees

    init(directed: Bool) {
        isDirected = directed
    }

    func contains(_ vertex: Vertex) -> Bool {
        targets[vertex] != nil
    }

    @discardableResult
    mutating func addVertex(_ vertex: Vertex) -> Bool {
        guard targets[vertex] == nil else { return false }
        targets[vertex] = []
        weights[vertex] = [:]
        incoming[vertex] = 0
        vertices.append(vertex)
        return true
    }

    @discardableResult
    mutating func addEdge(from: Vertex, to: Vertex, weight: Int = 1) -> Bool {
        addVertex(from)
        addVertex(to)
        let isNew = link(from, to, weight)
        if !isDirected && from != to {
            link(to, from, weight)                     // the way back, unless it's a self-loop
        }
        if isNew {
            edgeCount += 1
        }
        return isNew
    }

    @discardableResult
    mutating func removeEdge(from: Vertex, to: Vertex) -> Bool {
        guard unlink(from, to) else { return false }
        if !isDirected && from != to {
            unlink(to, from)
        }
        edgeCount -= 1
        return true
    }

    func neighbors(of vertex: Vertex) -> [(vertex: Vertex, weight: Int)] {
        guard let list = targets[vertex], let weight = weights[vertex] else { return [] }
        return list.map { (vertex: $0, weight: weight[$0]!) }
    }

    func outDegree(of vertex: Vertex) -> Int { targets[vertex]?.count ?? 0 }
    func inDegree(of vertex: Vertex) -> Int { incoming[vertex] ?? 0 }
    func degree(of vertex: Vertex) -> Int {
        isDirected ? inDegree(of: vertex) + outDegree(of: vertex) : outDegree(of: vertex)
    }

    @discardableResult
    private mutating func link(_ from: Vertex, _ to: Vertex, _ weight: Int) -> Bool {
        let isNew = weights[from]!.updateValue(weight, forKey: to) == nil
        if isNew {
            targets[from]!.append(to)
            incoming[to]! += 1
        }
        return isNew
    }

    @discardableResult
    private mutating func unlink(_ from: Vertex, _ to: Vertex) -> Bool {
        guard weights[from]?.removeValue(forKey: to) != nil else { return false }
        targets[from]!.remove(at: targets[from]!.firstIndex(of: to)!)
        incoming[to]! -= 1
        return true
    }
}

extension Graph: CustomStringConvertible {
    var description: String {
        let arrow = isDirected ? "->" : "--"
        var lines = ["Graph(\(isDirected ? "directed" : "undirected"), \(vertices.count) vertices, \(edgeCount) edges)"]
        for vertex in vertices {
            let listed = neighbors(of: vertex).map { $0.weight == 1 ? "\($0.vertex)" : "\($0.vertex)(\($0.weight))" }
            lines.append("\(vertex) \(arrow) \(listed.isEmpty ? "(none)" : listed.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }
}

var roads = Graph<String>(directed: false)
roads.addEdge(from: "Leeds", to: "York", weight: 40)
roads.addEdge(from: "Leeds", to: "Hull", weight: 95)
roads.addEdge(from: "York", to: "Hull", weight: 61)
roads.addVertex("Whitby")
print(roads)
print("Hull:", roads.neighbors(of: "Hull"))
print("new edge?", roads.addEdge(from: "Hull", to: "Leeds", weight: 90), "edges:", roads.edgeCount)
print("Leeds:", roads.neighbors(of: "Leeds").map { "\($0.vertex) \($0.weight)" })

var recipe = Graph<String>(directed: true)
recipe.addEdge(from: "shop", to: "cook")
recipe.addEdge(from: "cook", to: "eat")
recipe.addEdge(from: "shop", to: "eat")
for step in recipe.vertices {
    print(step, "in:", recipe.inDegree(of: step), "out:", recipe.outDegree(of: step))
}

var draft = recipe                                     // a copy: Graph is a struct
draft.removeEdge(from: "shop", to: "eat")
print("recipe:", recipe.edgeCount, "edges, draft:", draft.edgeCount, "edges")
