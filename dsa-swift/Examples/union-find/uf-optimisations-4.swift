// Generated from src/dsa/content/lessons/union-find/uf-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

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
        while parent[root] != root { root = parent[root] }   // walk up to the root
        var node = x
        while node != root {                                 // path compression
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
        if rootA == rootB { return false }                   // already in one set
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA                                // smaller tree under the larger
        size[rootA] += size[rootB]
        componentCount -= 1
        return true
    }

    mutating func connected(_ a: Int, _ b: Int) -> Bool {
        find(a) == find(b)
    }

    mutating func size(ofSetContaining x: Int) -> Int {
        size[find(x)]
    }
}

var sets = UnionFind(count: 8)
for (a, b) in [(0, 1), (2, 3), (1, 3), (4, 5), (6, 7), (5, 7)] {
    sets.union(a, b)
}
print("sets:", sets.componentCount)
print("0 and 2 together?", sets.connected(0, 2))
print("3 and 4 together?", sets.connected(3, 4))
print("size of 6's set:", sets.size(ofSetContaining: 6))
print("union(0, 3) joined anything?", sets.union(0, 3))
