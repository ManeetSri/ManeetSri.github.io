// Generated from src/dsa/content/lessons/union-find/uf-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SizedUnionFind {
    var parent: [Int]
    var size: [Int]

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }

    func find(_ x: Int) -> Int {
        var node = x
        while parent[node] != node { node = parent[node] }
        return node
    }

    func depth(_ x: Int) -> Int {
        var node = x
        var links = 0
        while parent[node] != node {
            node = parent[node]
            links += 1
        }
        return links
    }

    mutating func union(_ a: Int, _ b: Int) {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return }
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA
        size[rootA] += size[rootB]
    }
}

var chain = SizedUnionFind(count: 1_024)
for i in 0..<1_023 {
    chain.union(i, i + 1)                 // the order that built a chain before
}
print("chain order: the deepest node is at depth", (0..<1_024).map { chain.depth($0) }.max()!)

var rounds = SizedUnionFind(count: 1_024)
var step = 1
while step < 1_024 {                      // pairs, then pairs of pairs, and so on
    for i in stride(from: 0, to: 1_024, by: 2 * step) {
        rounds.union(i, i + step)
    }
    step *= 2
}
print("equal merges in rounds: the deepest node is at depth", (0..<1_024).map { rounds.depth($0) }.max()!)
