// Generated from src/dsa/content/lessons/union-find/uf-provinces.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from the last lesson
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

    @discardableResult
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

let friendships = [[0, 1], [2, 3], [1, 4], [5, 6], [4, 0]]
var people = UnionFind(count: 8)
for pair in friendships {
    let joined = people.union(pair[0], pair[1])
    print("\(pair[0])–\(pair[1]):", joined ? "two groups join" : "already one group", "->", people.componentCount, "groups")
}
