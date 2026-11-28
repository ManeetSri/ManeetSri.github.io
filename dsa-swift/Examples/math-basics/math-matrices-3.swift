// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func transpose(_ m: [[Int]]) -> [[Int]] {
    var t = Array(repeating: Array(repeating: 0, count: m.count), count: m[0].count)
    for i in 0..<m.count {
        for j in 0..<m[0].count {
            t[j][i] = m[i][j]
        }
    }
    return t
}

print(transpose([[1, 0, 2], [0, 3, 1]]))
