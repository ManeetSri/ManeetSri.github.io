// Generated from src/dsa/content/lessons/advanced-graphs/ag-lca-binary-lifting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A chain of 100,000 generations: person i's parent is i - 1
let n = 100_000
let parent = (0..<n).map { $0 - 1 }

var levels = 1
while (1 << levels) < n { levels += 1 }
var up = [(0..<n).map { parent[$0] == -1 ? $0 : parent[$0] }]
for k in 1..<levels {
    let previous = up[k - 1]
    up.append(previous.map { previous[$0] })
}
let depth = Array(0..<n)                       // in a chain, person i is i generations down

var jumps = 0
func ancestor(of v: Int, generationsUp k: Int) -> Int {
    if k > depth[v] { return -1 }
    var v = v
    for bit in 0..<levels where (k >> bit) & 1 == 1 {
        v = up[bit][v]
        jumps += 1
    }
    return v
}

func lowestCommonAncestor(_ a: Int, _ b: Int) -> Int {
    var (u, v) = depth[a] >= depth[b] ? (a, b) : (b, a)
    u = ancestor(of: u, generationsUp: depth[u] - depth[v])
    if u == v { return u }
    for k in stride(from: levels - 1, through: 0, by: -1) where up[k][u] != up[k][v] {
        u = up[k][u]
        v = up[k][v]
        jumps += 1
    }
    return up[0][u]
}

print("levels:", levels, "table entries:", levels * n)
print(ancestor(of: 99_999, generationsUp: 99_999), "after", jumps, "jumps")
jumps = 0
print(ancestor(of: 99_999, generationsUp: 65_537), "after", jumps, "jumps")
jumps = 0
print(lowestCommonAncestor(99_999, 31_416), "after", jumps, "jumps")
print("walking up one parent at a time would take", 99_999 - 31_416, "steps")
