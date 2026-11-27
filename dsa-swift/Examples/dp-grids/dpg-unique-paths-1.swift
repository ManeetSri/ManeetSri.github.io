// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

// Routes from the start to (row, col), moving only right or down
func routes(_ row: Int, _ col: Int) -> Int {
    calls += 1
    if row == 0 || col == 0 {
        return 1                         // the top row or left column: one straight line
    }
    return routes(row - 1, col) + routes(row, col - 1)
}

print(routes(2, 3), "routes from", calls, "calls")
calls = 0
print(routes(12, 12), "routes from", calls, "calls")
