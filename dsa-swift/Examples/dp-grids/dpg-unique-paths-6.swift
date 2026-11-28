// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countRoutes(_ floor: [[Int]]) -> Int {
    let cols = floor[0].count
    var row = Array(repeating: 0, count: cols)
    row[0] = 1                                   // the route that starts at the start
    for r in floor.indices {
        for c in 0..<cols {
            if floor[r][c] == 1 {
                row[c] = 0
            } else if c > 0 {
                row[c] += row[c - 1]
            }
        }
    }
    return row[cols - 1]
}

print(countRoutes([[0, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [1, 0, 0, 0]]))
print(countRoutes([[0, 1, 0], [0, 0, 0]]))
print(countRoutes([[0, 0], [1, 0], [0, 1]]))
print(countRoutes([[1]]))
