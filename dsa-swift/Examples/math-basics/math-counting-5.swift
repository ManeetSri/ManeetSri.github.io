// Generated from src/dsa/content/lessons/math-basics/math-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007
let size = 1000
var c = Array(repeating: Array(repeating: 0, count: size + 1), count: size + 1)
for n in 0...size {
    c[n][0] = 1
    if n > 0 {
        for k in 1...n {
            c[n][k] = (c[n - 1][k - 1] + c[n - 1][k]) % mod
        }
    }
}
print(c[10][3], c[1000][1], c[1000][500])
