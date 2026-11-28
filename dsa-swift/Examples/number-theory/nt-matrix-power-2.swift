// Generated from src/dsa/content/lessons/number-theory/nt-matrix-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007
typealias Matrix = [[Int]]

func multiply(_ a: Matrix, _ b: Matrix) -> Matrix {
    var c = Array(repeating: Array(repeating: 0, count: b[0].count), count: a.count)
    for i in 0..<a.count {
        for t in 0..<b.count {
            for j in 0..<b[0].count {
                c[i][j] = (c[i][j] + a[i][t] * b[t][j]) % mod
            }
        }
    }
    return c
}

func power(_ base: Matrix, _ exponent: Int) -> Matrix {
    var result = (0..<base.count).map { i in (0..<base.count).map { j in i == j ? 1 : 0 } }
    var square = base
    var e = exponent
    while e > 0 {
        if e & 1 == 1 { result = multiply(result, square) }
        square = multiply(square, square)
        e >>= 1
    }
    return result
}

func modPow(_ base: Int, _ exponent: Int) -> Int {
    var result = 1, square = base % mod, e = exponent
    while e > 0 {
        if e & 1 == 1 { result = result * square % mod }
        square = square * square % mod
        e >>= 1
    }
    return result
}

// Walks in a triangle: every vertex joined to the other two
let triangle: Matrix = [[0, 1, 1], [1, 0, 1], [1, 1, 0]]
print(power(triangle, 4))
let n = 1_000_000_000_000_000_000
let walks = power(triangle, n)[0][0]
// closed form (2^n + 2·(-1)^n) / 3, dividing by 3 with a Fermat inverse
let formula = (modPow(2, n) + (n % 2 == 0 ? 2 : mod - 2)) % mod * modPow(3, mod - 2) % mod
print(walks, formula)

// The running sum of Fibonacci numbers, carried along as a third entry of the state
let fibWithSum: Matrix = [[1, 1, 0],
                          [1, 0, 0],
                          [1, 0, 1]]
for steps in [5, 10] {
    let state = multiply(power(fibWithSum, steps), [[1], [0], [0]])   // start: [F(1), F(0), S(0)]
    print(steps, state.map { $0[0] })
}
let big = multiply(power(fibWithSum, n), [[1], [0], [0]]).map { $0[0] }
let fibPlus2 = power([[1, 1], [1, 0]], n + 2)[0][1]
print(big[2], (fibPlus2 - 1 + mod) % mod)
