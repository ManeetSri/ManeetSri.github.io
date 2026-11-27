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

func extraCable(_ cables: [[Int]]) -> [Int] {
    var network = UnionFind(count: cables.count)      // n cables for n computers
    for cable in cables {
        if !network.union(cable[0], cable[1]) {
            return cable                               // its ends were already connected
        }
    }
    return []
}

print(extraCable([[0, 1], [1, 2], [3, 4], [2, 3], [4, 1]]))
print(extraCable([[0, 1], [0, 2], [2, 1], [1, 3]]))
