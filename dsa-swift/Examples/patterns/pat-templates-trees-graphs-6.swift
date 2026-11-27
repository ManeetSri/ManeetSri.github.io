// Generated from src/dsa/content/lessons/patterns/pat-templates-trees-graphs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Union-find: groups that only ever merge, with near-constant time per operation
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]
    private(set) var groups: Int

    init(_ count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
        groups = count
    }

    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root { root = parent[root] }
        var node = x
        while node != root {                      // path compression: point everything at the root
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }

    @discardableResult
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return false }        // already together: this edge closes a cycle
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA                     // union by size: the smaller tree goes under
        size[rootA] += size[rootB]
        groups -= 1
        return true
    }
}

var network = UnionFind(6)
for (a, b) in [(0, 1), (1, 2), (3, 4), (2, 0), (4, 5)] {
    let joined = network.union(a, b)
    print("link \(a)-\(b):", joined ? "joined" : "redundant", "· groups:", network.groups)
}
print(network.find(0) == network.find(2), network.find(0) == network.find(5))
