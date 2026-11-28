// Reference solution: Strassen with a cutoff. At size `cutoff` or below, the standard triple loop
// (n³ multiplications). Above it, split both matrices into quarters, form Strassen's seven products
// recursively, and assemble the four quarters of the answer with additions and subtractions only.
// M(n) = 7 · M(n / 2) above the cutoff, so O(n^2.807) multiplications; the 18 block additions per
// level add O(n²) each. Recursion depth is log₂ n.

public enum StrassenSevenProducts {
    public typealias Matrix = [[Int]]

    public static func multiply(_ a: Matrix, _ b: Matrix, cutoff: Int) -> (product: Matrix, multiplications: Int) {
        var multiplications = 0

        func standard(_ a: Matrix, _ b: Matrix) -> Matrix {
            let n = a.count
            var c = Array(repeating: Array(repeating: 0, count: n), count: n)
            for i in 0..<n {
                for k in 0..<n {
                    let aik = a[i][k]
                    for j in 0..<n {
                        c[i][j] += aik * b[k][j]
                    }
                }
            }
            multiplications += n * n * n
            return c
        }

        func strassen(_ a: Matrix, _ b: Matrix) -> Matrix {
            let n = a.count
            if n <= cutoff { return standard(a, b) }
            let h = n / 2
            let (a11, a12, a21, a22) = (quarter(a, 0, 0), quarter(a, 0, h), quarter(a, h, 0), quarter(a, h, h))
            let (b11, b12, b21, b22) = (quarter(b, 0, 0), quarter(b, 0, h), quarter(b, h, 0), quarter(b, h, h))
            let m1 = strassen(add(a11, a22), add(b11, b22))
            let m2 = strassen(add(a21, a22), b11)
            let m3 = strassen(a11, subtract(b12, b22))
            let m4 = strassen(a22, subtract(b21, b11))
            let m5 = strassen(add(a11, a12), b22)
            let m6 = strassen(subtract(a21, a11), add(b11, b12))
            let m7 = strassen(subtract(a12, a22), add(b21, b22))
            let c11 = add(subtract(add(m1, m4), m5), m7)
            let c12 = add(m3, m5)
            let c21 = add(m2, m4)
            let c22 = add(add(subtract(m1, m2), m3), m6)
            return zip(c11, c12).map { $0 + $1 } + zip(c21, c22).map { $0 + $1 }
        }

        let product = strassen(a, b)
        return (product, multiplications)
    }

    /// The half-size block whose top-left corner is at (row, column)
    private static func quarter(_ m: Matrix, _ row: Int, _ column: Int) -> Matrix {
        let half = m.count / 2
        return m[row..<(row + half)].map { Array($0[column..<(column + half)]) }
    }

    private static func add(_ a: Matrix, _ b: Matrix) -> Matrix {
        zip(a, b).map { zip($0, $1).map(+) }
    }

    private static func subtract(_ a: Matrix, _ b: Matrix) -> Matrix {
        zip(a, b).map { zip($0, $1).map(-) }
    }
}
