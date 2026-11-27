// Generated from src/dsa/content/lessons/divide-conquer/dc-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fibonacci numbers by fast power of the matrix [[1, 1], [1, 0]], modulo m
typealias Matrix2 = (a: Int, b: Int, c: Int, d: Int)     // [[a, b], [c, d]]
let m = 1_000_000_007

func multiply(_ p: Matrix2, _ q: Matrix2) -> Matrix2 {
    (a: (p.a * q.a + p.b * q.c) % m, b: (p.a * q.b + p.b * q.d) % m,
     c: (p.c * q.a + p.d * q.c) % m, d: (p.c * q.b + p.d * q.d) % m)
}

func power(_ matrix: Matrix2, _ n: Int) -> Matrix2 {
    if n == 0 {
        return (a: 1, b: 0, c: 0, d: 1)                    // the identity matrix: "multiply by nothing"
    }
    let half = power(matrix, n / 2)
    let square = multiply(half, half)
    return n % 2 == 0 ? square : multiply(square, matrix)
}

// [[1, 1], [1, 0]] to the power n is [[F(n + 1), F(n)], [F(n), F(n - 1)]]
func fibonacci(_ n: Int) -> Int {
    power((a: 1, b: 1, c: 1, d: 0), n).b
}

print(fibonacci(10), fibonacci(50))
print(fibonacci(1_000_000_000_000_000_000))
