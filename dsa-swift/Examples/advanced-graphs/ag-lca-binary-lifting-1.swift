// Generated from src/dsa/content/lessons/advanced-graphs/ag-lca-binary-lifting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let parent = [-1, 0, 0, 1, 1, 2, 3, 4, 5, 6, 6, 9, 7]
let n = parent.count

// Depths: a BFS from the root visits every parent before its children, with no recursion
var children = [[Int]](repeating: [], count: n)
var root = 0
for v in 0..<n {
    if parent[v] == -1 { root = v } else { children[parent[v]].append(v) }
}
var depth = [Int](repeating: 0, count: n)
var order = [root]
var front = 0
while front < order.count {
    let v = order[front]
    front += 1
    for child in children[v] {
        depth[child] = depth[v] + 1
        order.append(child)
    }
}
print("depth:", depth)

// up[k][v] is v's 2^k-th ancestor. The root is its own parent, so jumps past it stay put.
var levels = 1
while (1 << levels) < n { levels += 1 }        // 2^levels > every depth
var up = [(0..<n).map { parent[$0] == -1 ? $0 : parent[$0] }]
for k in 1..<levels {
    let previous = up[k - 1]
    up.append(previous.map { previous[$0] })    // two jumps of 2^(k-1)
}
for k in 0..<levels {
    print("up[\(k)]:", up[k])
}

func ancestor(of v: Int, generationsUp k: Int) -> Int {
    if k > depth[v] { return -1 }
    var v = v
    for bit in 0..<levels where (k >> bit) & 1 == 1 {
        v = up[bit][v]                          // one jump per set bit of k
    }
    return v
}

func lowestCommonAncestor(_ a: Int, _ b: Int) -> Int {
    var (u, v) = depth[a] >= depth[b] ? (a, b) : (b, a)
    u = ancestor(of: u, generationsUp: depth[u] - depth[v])   // 1. same depth
    if u == v { return u }
    for k in stride(from: levels - 1, through: 0, by: -1) where up[k][u] != up[k][v] {
        u = up[k][u]                            // 2. jump both while they stay apart
        v = up[k][v]
    }
    return up[0][u]                             // 3. one step to where they meet
}

print("3 generations above 11:", ancestor(of: 11, generationsUp: 3))
print("5 generations above 11:", ancestor(of: 11, generationsUp: 5))
print("4 generations above 8:", ancestor(of: 8, generationsUp: 4))
for (a, b) in [(11, 10), (11, 12), (8, 12), (6, 11)] {
    let meet = lowestCommonAncestor(a, b)
    print("LCA(\(a), \(b)) = \(meet), distance \(depth[a] + depth[b] - 2 * depth[meet])")
}
