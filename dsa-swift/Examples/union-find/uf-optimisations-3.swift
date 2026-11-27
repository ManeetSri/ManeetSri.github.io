// Generated from src/dsa/content/lessons/union-find/uf-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct CountingUnionFind {
    var parent: [Int]
    var size: [Int]
    let bySize: Bool
    let compress: Bool
    var steps = 0                                // parent links followed, in total

    init(count: Int, bySize: Bool, compress: Bool) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
        self.bySize = bySize
        self.compress = compress
    }

    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root {
            root = parent[root]
            steps += 1
        }
        if compress {
            var node = x
            while node != root {
                let next = parent[node]
                parent[node] = root
                node = next
            }
        }
        return root
    }

    mutating func union(_ a: Int, _ b: Int) {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return }
        if bySize && size[rootA] > size[rootB] {
            swap(&rootA, &rootB)                 // make rootA the smaller tree
        }
        parent[rootA] = rootB
        size[rootB] += size[rootA]
    }
}

// The same operations for every version: unions that build a chain, then a seeded mix
var seed: UInt64 = 2024
func random(below limit: Int) -> Int {
    seed = seed &* 6364136223846793005 &+ 1442695040888963407
    return Int((seed >> 33) % UInt64(limit))
}
let n = 4_096
let chain = (0..<(n / 2 - 1)).map { (union: true, a: $0, b: $0 + 1) }
let mix = (0..<20_000).map { step in (union: step % 2 == 0, a: random(below: n), b: random(below: n)) }

for (name, bySize, compress) in [("naive", false, false), ("union by size", true, false),
                                 ("path compression", false, true), ("both", true, true)] {
    var sets = CountingUnionFind(count: n, bySize: bySize, compress: compress)
    for operation in chain + mix {
        if operation.union {
            sets.union(operation.a, operation.b)
        } else {
            _ = sets.find(operation.a)
            _ = sets.find(operation.b)
        }
    }
    print("\(name): \(sets.steps) steps")
}
