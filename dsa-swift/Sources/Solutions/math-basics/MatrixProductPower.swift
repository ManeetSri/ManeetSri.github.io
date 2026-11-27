// Reference solution: Matrix product and power. The product is the triple loop, O(r × c × k). The power
// is square-and-multiply starting from the identity, reducing after every multiply-and-add:
// O(k³ log exponent).

public enum MatrixProductPower {
    public static func product(_ a: [[Int]], _ b: [[Int]]) -> [[Int]]? {
        guard a[0].count == b.count else {
            return nil                                   // the inner sizes must match
        }
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

    public static func identity(size: Int) -> [[Int]] {
        var m = Array(repeating: Array(repeating: 0, count: size), count: size)
        for i in 0..<size {
            m[i][i] = 1
        }
        return m
    }

    static func multiply(_ a: [[Int]], _ b: [[Int]], modulo: Int) -> [[Int]] {
        let k = a.count
        var c = Array(repeating: Array(repeating: 0, count: k), count: k)
        for i in 0..<k {
            for j in 0..<k {
                for t in 0..<k {
                    c[i][j] = (c[i][j] + a[i][t] * b[t][j]) % modulo   // each product is below about 10¹⁸
                }
            }
        }
        return c
    }

    public static func power(_ m: [[Int]], _ exponent: Int, modulo: Int) -> [[Int]] {
        var result = identity(size: m.count)            // m⁰
        var square = m                                   // m, m², m⁴, …
        var e = exponent
        while e > 0 {
            if e % 2 == 1 {
                result = multiply(result, square, modulo: modulo)
            }
            square = multiply(square, square, modulo: modulo)
            e /= 2
        }
        return result
    }
}
