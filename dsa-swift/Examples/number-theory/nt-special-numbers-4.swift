// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Stirling numbers of the second kind: S(n, k) = k·S(n-1, k) + S(n-1, k-1)
let size = 7
var second = Array(repeating: Array(repeating: 0, count: size + 1), count: size + 1)
second[0][0] = 1
for n in stride(from: 1, through: size, by: 1) {
    for k in stride(from: 1, through: n, by: 1) {
        second[n][k] = k * second[n - 1][k] + second[n - 1][k - 1]
    }
}
for n in 1...size {
    print(n, Array(second[n][1...n]), "sum:", second[n].reduce(0, +))
}
