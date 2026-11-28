// Generated from src/dsa/content/lessons/mst/mst-definition.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

typealias Edge = (from: String, to: String, weight: Int)

/// True when the chosen edges connect all the vertices with no cycle
func isSpanningTree(_ chosen: [Edge], _ vertices: [String]) -> Bool {
    var parent = Dictionary(uniqueKeysWithValues: vertices.map { ($0, $0) })
    func root(_ x: String) -> String {
        var x = x
        while parent[x]! != x { x = parent[x]! }
        return x
    }
    for edge in chosen {
        let (rootA, rootB) = (root(edge.from), root(edge.to))
        if rootA == rootB { return false }          // this edge would close a cycle
        parent[rootA] = rootB
    }
    return chosen.count == vertices.count - 1      // no cycle and V − 1 edges: connected
}

/// Tries every set of V − 1 edges and reports the spanning trees and the lightest ones
func survey(_ vertices: [String], _ edges: [Edge]) {
    var trees = 0
    var best = Int.max
    var lightest: [[Edge]] = []
    for mask in 0..<(1 << edges.count) where mask.nonzeroBitCount == vertices.count - 1 {
        let chosen = edges.indices.filter { mask & (1 << $0) != 0 }.map { edges[$0] }
        guard isSpanningTree(chosen, vertices) else { continue }
        trees += 1
        let weight = chosen.reduce(0) { $0 + $1.weight }
        if weight < best {
            best = weight
            lightest = [chosen]
        } else if weight == best {
            lightest.append(chosen)
        }
    }
    print("\(trees) spanning trees; lightest weight \(best), reached by \(lightest.count)")
    for tree in lightest {
        print("  " + tree.map { "\($0.from)\($0.to) \($0.weight)" }.joined(separator: ", "))
    }
}

survey(["A", "B", "C", "D", "E", "F"],
       [("A", "B", 4), ("A", "C", 2), ("B", "C", 1), ("B", "D", 5),
        ("C", "E", 10), ("D", "E", 2), ("D", "F", 6), ("E", "F", 3)])
survey(["P", "Q", "R", "S"], [("P", "Q", 1), ("Q", "R", 1), ("R", "S", 1), ("S", "P", 1), ("P", "R", 2)])
