// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func multiply(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
    let rows = a.count
    let inner = b.count
    let cols = b[0].count
    var c = Array(repeating: Array(repeating: 0, count: cols), count: rows)
    for i in 0..<rows {
        for j in 0..<cols {
            for t in 0..<inner {
                c[i][j] += a[i][t] * b[t][j]
            }
        }
    }
    return c
}

print(multiply([[1, 2], [3, 4]], [[5, 6], [7, 8]]))
print(multiply([[1, 0, 2], [0, 3, 1]], [[1, 2], [0, 1], [4, 0]]))
