// Generated from src/dsa/content/lessons/union-find/uf-provinces.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from the last lesson
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

func isTree(_ n: Int, _ links: [[Int]]) -> Bool {
    guard links.count == n - 1 else { return false }
    var nodes = UnionFind(count: n)
    for link in links where !nodes.union(link[0], link[1]) {
        return false                       // this link closes a cycle
    }
    return true
}

print(isTree(5, [[0, 1], [0, 2], [2, 3], [2, 4]]))
print(isTree(5, [[0, 1], [1, 2], [2, 0], [3, 4]]))
print(isTree(4, [[0, 1], [2, 3]]))
print(isTree(1, []))
