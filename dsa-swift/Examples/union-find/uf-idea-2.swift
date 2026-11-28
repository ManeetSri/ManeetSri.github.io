// Generated from src/dsa/content/lessons/union-find/uf-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct NaiveUnionFind {
    var parent: [Int]

    init(count: Int) {
        parent = Array(0..<count)     // every element is its own root
    }

    func find(_ x: Int) -> Int {
        var node = x
        while parent[node] != node {  // walk up until a node is its own parent
            node = parent[node]
        }
        return node
    }

    mutating func union(_ a: Int, _ b: Int) -> Bool {
        let rootA = find(a)
        let rootB = find(b)
        if rootA == rootB { return false }   // already in one set
        parent[rootA] = rootB                 // a's whole tree hangs under b's root
        return true
    }
}

var sets = NaiveUnionFind(count: 6)
print("start:", sets.parent)
for (a, b) in [(0, 1), (2, 3), (1, 3), (4, 5), (0, 2)] {
    let joined = sets.union(a, b)
    print("union(\(a), \(b)) -> \(joined), parent = \(sets.parent)")
}
print("find(0) =", sets.find(0), "and find(5) =", sets.find(5))
