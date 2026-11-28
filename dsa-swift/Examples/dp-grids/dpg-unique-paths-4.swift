// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// C(n, k) with the multiplicative formula, or nil if a step overflows
func choose(_ n: Int, _ k: Int) -> Int? {
    let k = min(k, n - k)
    var result = 1
    for i in 0..<k {
        let (product, overflow) = result.multipliedReportingOverflow(by: n - i)
        if overflow {
            return nil
        }
        result = product / (i + 1)
    }
    return result
}

func countRoutes(rows: Int, cols: Int) -> Int {
    var row = Array(repeating: 1, count: cols)
    for _ in 1..<rows {
        for c in 1..<cols {
            row[c] += row[c - 1]
        }
    }
    return row[cols - 1]
}

for (rows, cols) in [(3, 7), (10, 10), (30, 30), (33, 33)] {
    let formula = choose(rows + cols - 2, rows - 1).map(String.init) ?? "overflow"
    print("\(rows) × \(cols): formula \(formula), table \(countRoutes(rows: rows, cols: cols))")
}
