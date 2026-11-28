// Generated from src/dsa/content/lessons/divide-conquer/dc-strassen.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

typealias Matrix = [[Int]]

var multiplications = 0
var additions = 0                                        // additions and subtractions

func standard(_ a: Matrix, _ b: Matrix) -> Matrix {
    let n = a.count
    var c = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in 0..<n {
        for j in 0..<n {
            for k in 0..<n {
                multiplications += 1
                additions += 1
                c[i][j] += a[i][k] * b[k][j]
            }
        }
    }
    return c
}

func add(_ a: Matrix, _ b: Matrix) -> Matrix {
    additions += a.count * a.count
    return zip(a, b).map { zip($0, $1).map(+) }
}

func subtract(_ a: Matrix, _ b: Matrix) -> Matrix {
    additions += a.count * a.count
    return zip(a, b).map { zip($0, $1).map(-) }
}

func quarter(_ m: Matrix, _ row: Int, _ column: Int) -> Matrix {   // the half-size block at (row, column)
    let half = m.count / 2
    return m[row..<(row + half)].map { Array($0[column..<(column + half)]) }
}

func joined(_ c11: Matrix, _ c12: Matrix, _ c21: Matrix, _ c22: Matrix) -> Matrix {
    zip(c11, c12).map { $0 + $1 } + zip(c21, c22).map { $0 + $1 }
}

// Strassen's algorithm, for n a power of two, recursing all the way down to single numbers
func strassen(_ a: Matrix, _ b: Matrix) -> Matrix {
    let n = a.count
    if n == 1 {
        multiplications += 1
        return [[a[0][0] * b[0][0]]]
    }
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
    return joined(add(subtract(add(m1, m4), m5), m7), add(m3, m5),
                  add(m2, m4), add(add(subtract(m1, m2), m3), m6))
}

// Fill an n × n matrix with small numbers that look random but are the same on every run
func sample(_ n: Int, _ salt: Int) -> Matrix {
    (0..<n).map { i in (0..<n).map { j in (i * 7 + j * 3 + salt) % 10 - 4 } }
}

for n in [2, 4, 8, 16, 32] {
    let a = sample(n, 1), b = sample(n, 5)
    (multiplications, additions) = (0, 0)
    let plain = standard(a, b)
    let plainCounts = (multiplications, additions)
    (multiplications, additions) = (0, 0)
    let fast = strassen(a, b)
    print("n = \(n): \(plain == fast ? "same" : "different!"), standard \(plainCounts.0) × and \(plainCounts.1) +, Strassen \(multiplications) × and \(additions) +")
}
