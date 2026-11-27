// Generated from src/dsa/content/lessons/mst/mst-boruvka.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from M45, with a count of components
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]
    private(set) var componentCount: Int

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
        componentCount = count
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
        componentCount -= 1
        return true
    }
}

func boruvka(_ names: [String], _ edges: [(Int, Int, Int)], listEdges: Bool = true) -> Int? {
    /// Edge a comes before edge b: by weight, then by position in the list, so no two edges tie
    func lighter(_ a: Int, _ b: Int) -> Bool {
        edges[a].2 != edges[b].2 ? edges[a].2 < edges[b].2 : a < b
    }
    var sets = UnionFind(count: names.count)
    var total = 0
    var round = 0
    while sets.componentCount > 1 {
        round += 1
        // cheapest[root]: the index of the lightest edge leaving that root's component, or -1
        var cheapest = Array(repeating: -1, count: names.count)
        for index in edges.indices {
            let rootA = sets.find(edges[index].0)
            let rootB = sets.find(edges[index].1)
            if rootA == rootB { continue }                   // inside one component
            for root in [rootA, rootB] where cheapest[root] == -1 || lighter(index, cheapest[root]) {
                cheapest[root] = index
            }
        }
        let chosen = Set(cheapest.filter { $0 >= 0 }).sorted()
        if chosen.isEmpty { return nil }                     // no edge leaves any component
        var added: [String] = []
        for index in chosen where sets.union(edges[index].0, edges[index].1) {
            total += edges[index].2
            added.append("\(names[edges[index].0])\(names[edges[index].1]) \(edges[index].2)")
        }
        let what = listEdges ? added.joined(separator: ", ") : "\(added.count) edge\(added.count == 1 ? "" : "s")"
        print("round \(round): add \(what); \(sets.componentCount) left")
    }
    return total
}

let names = ["A", "B", "C", "D", "E", "F"]
let edges = [(0, 1, 4), (0, 2, 2), (1, 2, 1), (1, 3, 5), (2, 4, 10), (3, 4, 2), (3, 5, 6), (4, 5, 3)]
print("total weight:", boruvka(names, edges)!)

// 16 vertices in a ring, each joined to the next, with weights 1 to 16 in a scrambled order
let ring = (0..<16).map { "v\($0)" }
let ringEdges = (0..<16).map { ($0, ($0 + 1) % 16, ($0 * 7) % 16 + 1) }
print("ring total:", boruvka(ring, ringEdges, listEdges: false)!)
