// Generated from src/dsa/content/lessons/shortest-paths/sp-floyd-warshall.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Transitive closure: can i reach j at all? Same loops, with || and && instead of min and +
let n = 4
var reach = Array(repeating: Array(repeating: false, count: n), count: n)
for i in 0..<n {
    reach[i][i] = true
}
for (from, to) in [(0, 1), (1, 2), (3, 2)] {
    reach[from][to] = true
}
for k in 0..<n {
    for i in 0..<n where reach[i][k] {
        for j in 0..<n where reach[k][j] {
            reach[i][j] = true
        }
    }
}
for i in 0..<n {
    print(i, "reaches", (0..<n).filter { reach[i][$0] })
}
