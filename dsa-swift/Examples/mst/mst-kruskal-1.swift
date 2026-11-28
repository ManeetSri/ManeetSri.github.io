// Generated from src/dsa/content/lessons/mst/mst-kruskal.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from M45
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }

    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root { root = parent[root] }
        var node = x
        while node != root {
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }

    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return false }
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA
        size[rootA] += size[rootB]
        return true
    }
}

typealias Edge = (from: Int, to: Int, weight: Int)

/// The MST's total weight and edges, or nil if the graph isn't connected
func kruskal(vertexCount: Int, edges: [Edge], names: [String]) -> (total: Int, tree: [Edge])? {
    var trees = UnionFind(count: vertexCount)
    var chosen: [Edge] = []
    var total = 0
    for edge in edges.sorted(by: { $0.weight < $1.weight }) {
        let label = "\(names[edge.from])\(names[edge.to]) \(edge.weight)"
        if trees.union(edge.from, edge.to) {
            chosen.append(edge)
            total += edge.weight
            print(label + ": take it")
            if chosen.count == vertexCount - 1 { break }     // the tree is complete
        } else {
            print(label + ": skip, its ends are already connected")
        }
    }
    guard chosen.count == vertexCount - 1 else { return nil }    // the graph isn't connected
    return (total, chosen)
}

let names = ["A", "B", "C", "D", "E", "F"]
let edges: [Edge] = [(0, 1, 4), (0, 2, 2), (1, 2, 1), (1, 3, 5), (2, 4, 10), (3, 4, 2), (3, 5, 6), (4, 5, 3)]
if let mst = kruskal(vertexCount: 6, edges: edges, names: names) {
    print("total weight:", mst.total)
}
