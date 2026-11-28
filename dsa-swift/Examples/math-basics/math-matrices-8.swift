// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007

func multiplyMod(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
    var c = [[0, 0], [0, 0]]
    for i in 0..<2 {
        for j in 0..<2 {
            for t in 0..<2 {
                c[i][j] = (c[i][j] + a[i][t] * b[t][j]) % mod
            }
        }
    }
    return c
}

func fibonacci(_ n: Int) -> Int {
    var result = [[1, 0], [0, 1]]
    var square = [[1, 1], [1, 0]]
    var e = n
    while e > 0 {
        if e % 2 == 1 {
            result = multiplyMod(result, square)
        }
        square = multiplyMod(square, square)
        e /= 2
    }
    return result[0][1]
}

print(fibonacci(10))
print(fibonacci(1000))
print(fibonacci(1_000_000_000_000_000_000))
