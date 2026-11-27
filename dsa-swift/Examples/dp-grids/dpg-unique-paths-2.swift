// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func routeTable(rows: Int, cols: Int) -> [[Int]] {
    // 1. State: ways[r][c] = routes from (0, 0) to (r, c)
    // 3. Base case: every cell in the top row and left column has exactly one route
    var ways = Array(repeating: Array(repeating: 1, count: cols), count: rows)
    // 4. Order: row by row, left to right
    for r in 1..<rows {
        for c in 1..<cols {
            // 2. Transition: from above, plus from the left
            ways[r][c] = ways[r - 1][c] + ways[r][c - 1]
        }
    }
    return ways
}

for row in routeTable(rows: 3, cols: 4) {
    print(row)
}
// 5. Answer: the bottom-right cell
print(routeTable(rows: 3, cols: 7)[2][6])
