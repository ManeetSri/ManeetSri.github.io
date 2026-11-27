// Generated from src/dsa/content/lessons/union-find/uf-online.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from "Path compression and union by rank"
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

let rows = 4
let columns = 5
var islands = UnionFind(count: rows * columns)
var isLand = Array(repeating: false, count: rows * columns)
var count = 0

func addLand(_ row: Int, _ column: Int) -> Int {
    let cell = row * columns + column
    if isLand[cell] { return count }                  // already land: nothing changes
    isLand[cell] = true
    count += 1                                        // a brand-new island of one cell
    for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
        let r = row + dr
        let c = column + dc
        guard r >= 0, r < rows, c >= 0, c < columns, isLand[r * columns + c] else { continue }
        if islands.union(cell, r * columns + c) {
            count -= 1                                // two islands became one
        }
    }
    return count
}

for (row, column) in [(0, 0), (0, 2), (1, 1), (2, 3), (0, 1), (2, 2), (1, 2), (0, 0), (3, 4)] {
    print("land at (\(row), \(column)) -> islands: \(addLand(row, column))")
}
for row in 0..<rows {
    print((0..<columns).map { isLand[row * columns + $0] ? "#" : "." }.joined())
}
