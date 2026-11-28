// Generated from src/dsa/content/lessons/tree-basics/tree-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The smallest height that can hold n nodes: the first h with 2^h - 1 >= n
func shortestHeight(_ n: Int) -> Int {
    var height = 0
    while (1 << height) - 1 < n {
        height += 1
    }
    return height
}

for n in [1, 7, 8, 100, 1_000, 1_000_000] {
    print("\(n) nodes: height between \(shortestHeight(n)) and \(n)")
}
