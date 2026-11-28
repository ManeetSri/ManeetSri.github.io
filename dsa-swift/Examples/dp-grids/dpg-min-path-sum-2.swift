// Generated from src/dsa/content/lessons/dp-grids/dpg-min-path-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestPath(_ grid: [[Int]]) -> Int {
    let cols = grid[0].count
    var cost = Array(repeating: 0, count: cols)
    for r in grid.indices {
        for c in 0..<cols {
            if r == 0 && c == 0 {
                cost[c] = grid[0][0]
            } else if r == 0 {
                cost[c] = grid[r][c] + cost[c - 1]                 // top row: from the left only
            } else if c == 0 {
                cost[c] = grid[r][c] + cost[c]                     // left column: from above only
            } else {
                cost[c] = grid[r][c] + min(cost[c], cost[c - 1])   // cost[c] is still "above"
            }
        }
    }
    return cost[cols - 1]
}

print(cheapestPath([[2, 3, 1, 4], [1, 7, 1, 2], [5, 2, 3, 1]]))
print(cheapestPath([[5]]))
print(cheapestPath([[1, 2, 3]]))
print(cheapestPath([[1], [2], [3]]))
