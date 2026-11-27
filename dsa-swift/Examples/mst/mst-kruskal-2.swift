// Generated from src/dsa/content/lessons/mst/mst-kruskal.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from M45, with a count of groups
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

let names = ["A", "B", "C", "D", "E", "F"]
let edges = [(0, 1, 4), (0, 2, 2), (1, 2, 1), (1, 3, 5), (2, 4, 10), (3, 4, 2), (3, 5, 6), (4, 5, 3)]
let k = 2
var groups = UnionFind(count: names.count)
for (a, b, weight) in edges.sorted(by: { $0.2 < $1.2 }) {
    if groups.componentCount == k {
        if groups.find(a) != groups.find(b) {          // the first edge that would join two clusters
            print("spacing:", weight, "(\(names[a])\(names[b]))")
            break
        }
        continue
    }
    _ = groups.union(a, b)
}
for root in Set(names.indices.map { groups.find($0) }).sorted() {
    print(names.indices.filter { groups.find($0) == root }.map { names[$0] }.joined(separator: " "))
}
