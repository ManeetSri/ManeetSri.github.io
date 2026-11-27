// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Unsigned Stirling numbers of the first kind: c(n, k) = (n-1)·c(n-1, k) + c(n-1, k-1)
let size = 6
var first = Array(repeating: Array(repeating: 0, count: size + 1), count: size + 1)
first[0][0] = 1
for n in stride(from: 1, through: size, by: 1) {
    for k in stride(from: 1, through: n, by: 1) {
        first[n][k] = (n - 1) * first[n - 1][k] + first[n - 1][k - 1]
    }
}
for n in 1...size {
    print(n, Array(first[n][1...n]), "sum:", first[n].reduce(0, +))
}
