// Generated from src/dsa/content/lessons/shortest-paths/sp-floyd-warshall.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let infinity = Int.max / 2
let names = ["A", "B", "C", "D"]
let edges = [(0, 1, 4), (1, 3, 2), (3, 2, 3)]  // one chain: A → B → D → C

func allPairs(kOutermost: Bool) -> [[Int]] {
    let n = names.count
    var dist = Array(repeating: Array(repeating: infinity, count: n), count: n)
    for i in 0..<n {
        dist[i][i] = 0
    }
    for (from, to, weight) in edges {
        dist[from][to] = weight
    }
    for a in 0..<n {
        for b in 0..<n {
            for c in 0..<n {
                let (k, i, j) = kOutermost ? (a, b, c) : (c, a, b)   // the wrong order puts k innermost
                if dist[i][k] < infinity && dist[k][j] < infinity && dist[i][k] + dist[k][j] < dist[i][j] {
                    dist[i][j] = dist[i][k] + dist[k][j]
                }
            }
        }
    }
    return dist
}

let right = allPairs(kOutermost: true)
let wrong = allPairs(kOutermost: false)
print("A to C, k outermost:", right[0][2])
print("A to C, k innermost:", wrong[0][2] == infinity ? "∞" : String(wrong[0][2]))
