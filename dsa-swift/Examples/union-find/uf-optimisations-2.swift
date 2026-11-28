// Generated from src/dsa/content/lessons/union-find/uf-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func compressed(_ start: [Int], from x: Int) -> [Int] {
    var parent = start
    var root = x
    while parent[root] != root { root = parent[root] }
    var node = x
    while node != root {
        let next = parent[node]
        parent[node] = root
        node = next
    }
    return parent
}

func halved(_ start: [Int], from x: Int) -> [Int] {
    var parent = start
    var node = x
    while parent[node] != node {
        parent[node] = parent[parent[node]]
        node = parent[node]
    }
    return parent
}

let chain = [1, 2, 3, 4, 5, 5]            // 0 → 1 → 2 → 3 → 4 → 5
print("before:     ", chain)
print("compression:", compressed(chain, from: 0))
print("halving:    ", halved(chain, from: 0))
