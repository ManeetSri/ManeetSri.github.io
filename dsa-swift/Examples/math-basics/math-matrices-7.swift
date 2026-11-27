// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func multiply(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
    var c = Array(repeating: Array(repeating: 0, count: b[0].count), count: a.count)
    for i in 0..<a.count {
        for j in 0..<b[0].count {
            for t in 0..<b.count {
                c[i][j] += a[i][t] * b[t][j]
            }
        }
    }
    return c
}

let m = [[1, 1], [1, 0]]
var power = m
for n in 2...6 {
    power = multiply(power, m)
    print(n, power)
}
