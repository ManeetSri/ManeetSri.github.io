// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func identity(_ n: Int) -> [[Int]] {
    var m = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in 0..<n {
        m[i][i] = 1
    }
    return m
}

print(identity(3))
