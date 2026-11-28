// Generated from src/dsa/content/lessons/dp-intervals/dpi-matrix-chain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func multiply(_ a: [[Int]], _ b: [[Int]]) -> (product: [[Int]], multiplications: Int) {
    let rows = a.count, inner = b.count, cols = b[0].count
    var product = Array(repeating: Array(repeating: 0, count: cols), count: rows)
    var multiplications = 0
    for r in 0..<rows {
        for c in 0..<cols {
            for k in 0..<inner {                       // row r of a times column c of b
                product[r][c] += a[r][k] * b[k][c]
                multiplications += 1
            }
        }
    }
    return (product, multiplications)
}

let result = multiply([[1, 2, 3], [4, 5, 6]], [[1, 0], [0, 1], [2, 2]])
print(result.product)
print(result.multiplications)
