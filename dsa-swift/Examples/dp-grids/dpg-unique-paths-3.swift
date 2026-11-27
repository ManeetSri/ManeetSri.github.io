// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countRoutes(rows: Int, cols: Int) -> Int {
    var row = Array(repeating: 1, count: cols)      // the top row
    for _ in 1..<rows {
        for c in 1..<cols {
            row[c] += row[c - 1]    // row[c] still says "from above"; row[c - 1] is already this row's
        }
    }
    return row[cols - 1]
}

print(countRoutes(rows: 3, cols: 7))
print(countRoutes(rows: 10, cols: 10))
print(countRoutes(rows: 1, cols: 5))
