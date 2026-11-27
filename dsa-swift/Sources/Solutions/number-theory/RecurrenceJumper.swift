// Reference solution: Jump along a recurrence. Keep the last k terms as a state vector
// [a(i), a(i − 1), …, a(i − k + 1)]. One step of the recurrence is a k × k companion matrix: its first
// row holds the coefficients, and the rows below shift every term down one place. So a(n) is the first
// entry of M^(n − k + 1) applied to [a(k − 1), …, a(0)], and fast exponentiation computes the power with
// O(log n) matrix products. Everything is reduced into 0..<p first, so negative inputs work, and every
// product is reduced before it's added, so sums never overflow. O(k³ log n) time, O(k²) space.

public enum RecurrenceJumper {
    private static let mod = 1_000_000_007

    public static func term(_ n: Int, coefficients: [Int], initial: [Int]) -> Int {
        let k = coefficients.count
        let start = initial.map { reduce($0) }
        if n < k { return start[n] }
        var step = Array(repeating: Array(repeating: 0, count: k), count: k)
        step[0] = coefficients.map { reduce($0) }
        for row in stride(from: 1, to: k, by: 1) {
            step[row][row - 1] = 1                      // a(i − row) moves down to the next slot
        }
        let jump = power(step, n - k + 1)
        var answer = 0
        for j in 0..<k {                                // first row of the power times [a(k − 1), …, a(0)]
            answer = (answer + jump[0][j] * start[k - 1 - j]) % mod
        }
        return answer
    }

    private static func reduce(_ value: Int) -> Int {
        ((value % mod) + mod) % mod
    }

    private static func multiply(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
        let size = a.count
        var c = Array(repeating: Array(repeating: 0, count: size), count: size)
        for i in 0..<size {
            for t in 0..<size where a[i][t] != 0 {
                for j in 0..<size {
                    c[i][j] = (c[i][j] + a[i][t] * b[t][j]) % mod
                }
            }
        }
        return c
    }

    private static func power(_ base: [[Int]], _ exponent: Int) -> [[Int]] {
        let size = base.count
        var result = (0..<size).map { i in (0..<size).map { j in i == j ? 1 : 0 } }
        var square = base
        var e = exponent
        while e > 0 {
            if e & 1 == 1 { result = multiply(result, square) }
            e >>= 1
            if e > 0 { square = multiply(square, square) }
        }
        return result
    }
}
