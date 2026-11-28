// Generated from src/dsa/content/lessons/mst/mst-problems.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from M45
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

/// Houses 1...n. Each can dig its own well, or be piped to another house that has water.
func cheapestWater(wellCost: [Int], pipes: [(Int, Int, Int)]) -> Int {
    let n = wellCost.count
    // Vertex 0 is the ground water: digging a well at house i is an edge 0–i
    var edges = pipes
    for house in 1...n {
        edges.append((0, house, wellCost[house - 1]))
    }
    var sets = UnionFind(count: n + 1)
    var total = 0
    for (a, b, cost) in edges.sorted(by: { $0.2 < $1.2 }) where sets.union(a, b) {
        print(a == 0 ? "dig a well at house \(b): \(cost)" : "pipe \(a)–\(b): \(cost)")
        total += cost
    }
    return total
}

print("total:", cheapestWater(wellCost: [5, 4, 6, 9], pipes: [(1, 2, 2), (2, 3, 3), (3, 4, 7), (1, 4, 8)]))
