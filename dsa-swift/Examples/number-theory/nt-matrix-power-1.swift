// Generated from src/dsa/content/lessons/number-theory/nt-matrix-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007
typealias Matrix = [[Int]]

func multiply(_ a: Matrix, _ b: Matrix) -> Matrix {
    let n = a.count, inner = b.count, m = b[0].count
    var c = Array(repeating: Array(repeating: 0, count: m), count: n)
    for i in 0..<n {
        for t in 0..<inner where a[i][t] != 0 {
            for j in 0..<m {
                c[i][j] = (c[i][j] + a[i][t] * b[t][j]) % mod   // reduce every product before the next one is added
            }
        }
    }
    return c
}

func identity(_ size: Int) -> Matrix {
    (0..<size).map { i in (0..<size).map { j in i == j ? 1 : 0 } }
}

func power(_ base: Matrix, _ exponent: Int) -> Matrix {
    var result = identity(base.count)
    var square = base
    var e = exponent
    while e > 0 {
        if e & 1 == 1 { result = multiply(result, square) }
        square = multiply(square, square)
        e >>= 1
    }
    return result
}

// Tribonacci: T(n) = T(n-1) + T(n-2) + T(n-3), starting 0, 1, 1
let step: Matrix = [[1, 1, 1],
                    [1, 0, 0],
                    [0, 1, 0]]
func tribonacci(_ n: Int) -> Int {
    if n < 3 { return [0, 1, 1][n] }
    let m = power(step, n - 2)
    let start: Matrix = [[1], [1], [0]]            // [T(2), T(1), T(0)] as a column
    return multiply(m, start)[0][0]
}

var slow = [0, 1, 1]
while slow.count < 15 { slow.append(slow[slow.count - 1] + slow[slow.count - 2] + slow[slow.count - 3]) }
print(slow)
print((0..<15).map(tribonacci))
print(tribonacci(1_000_000_000_000_000_000))
