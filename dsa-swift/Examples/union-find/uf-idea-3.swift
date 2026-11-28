// Generated from src/dsa/content/lessons/union-find/uf-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct NaiveUnionFind {
    var parent: [Int]

    init(count: Int) {
        parent = Array(0..<count)
    }

    func find(_ x: Int) -> Int {
        var node = x
        while parent[node] != node { node = parent[node] }
        return node
    }

    /// How many parent links find(x) follows
    func steps(_ x: Int) -> Int {
        var node = x
        var count = 0
        while parent[node] != node {
            node = parent[node]
            count += 1
        }
        return count
    }

    mutating func union(_ a: Int, _ b: Int) {
        let rootA = find(a)
        let rootB = find(b)
        if rootA != rootB { parent[rootA] = rootB }
    }
}

for n in [10, 100, 1_000] {
    var sets = NaiveUnionFind(count: n)
    for i in 0..<(n - 1) {
        sets.union(i, i + 1)
    }
    let total = (0..<n).reduce(0) { $0 + sets.steps($1) }
    print("n = \(n): find(0) takes \(sets.steps(0)) steps; one find on every element takes \(total)")
}
