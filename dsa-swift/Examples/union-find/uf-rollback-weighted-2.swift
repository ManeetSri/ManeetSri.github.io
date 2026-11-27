// Generated from src/dsa/content/lessons/union-find/uf-rollback-weighted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct RatioUnionFind {
    private var parent: [Int] = []
    private var weight: [Double] = []      // weight[x] = x / parent[x]
    private var size: [Int] = []

    mutating func addElement() -> Int {
        parent.append(parent.count)
        weight.append(1)
        size.append(1)
        return parent.count - 1
    }

    /// The root of x, and the ratio x / root. Compresses the path, keeping each weight right.
    mutating func find(_ x: Int) -> (root: Int, ratio: Double) {
        var path: [Int] = []
        var root = x
        while parent[root] != root {
            path.append(root)
            root = parent[root]
        }
        for node in path.reversed() where parent[node] != root {
            weight[node] *= weight[parent[node]]     // its parent already points at the root
            parent[node] = root
        }
        return (root, x == root ? 1 : weight[x])
    }

    /// Records a / b = k. Returns false if a and b were already related.
    mutating func union(_ a: Int, _ b: Int, ratio k: Double) -> Bool {
        let (rootA, ratioA) = find(a)               // a = ratioA · rootA
        let (rootB, ratioB) = find(b)               // b = ratioB · rootB
        if rootA == rootB { return false }
        let rootRatio = k * ratioB / ratioA         // rootA / rootB
        if size[rootA] < size[rootB] {
            parent[rootA] = rootB
            weight[rootA] = rootRatio
            size[rootB] += size[rootA]
        } else {
            parent[rootB] = rootA
            weight[rootB] = 1 / rootRatio
            size[rootA] += size[rootB]
        }
        return true
    }

    /// a / b, or nil if the facts so far don't determine it
    mutating func ratio(_ a: Int, _ b: Int) -> Double? {
        let (rootA, ratioA) = find(a)
        let (rootB, ratioB) = find(b)
        return rootA == rootB ? ratioA / ratioB : nil
    }
}

var facts = RatioUnionFind()
var indexOf: [String: Int] = [:]
func index(_ name: String) -> Int {
    if let known = indexOf[name] { return known }
    let new = facts.addElement()
    indexOf[name] = new
    return new
}

for (a, b, k) in [("a", "b", 2.0), ("b", "c", 4.0), ("d", "e", 0.5), ("a", "c", 9.0)] {
    let (x, y) = (index(a), index(b))
    if !facts.union(x, y, ratio: k), let known = facts.ratio(x, y), abs(known - k) > 1e-9 {
        print("\(a) / \(b) = \(k) contradicts what's known: \(known)")
    }
}
for (a, b) in [("a", "c"), ("c", "a"), ("b", "a"), ("e", "d"), ("a", "e"), ("x", "x")] {
    if let x = indexOf[a], let y = indexOf[b], let value = facts.ratio(x, y) {
        print("\(a) / \(b) = \(value)")
    } else {
        print("\(a) / \(b) is unknown")
    }
}
