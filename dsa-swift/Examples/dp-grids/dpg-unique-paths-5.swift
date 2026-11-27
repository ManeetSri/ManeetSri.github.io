// Generated from src/dsa/content/lessons/dp-grids/dpg-unique-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 1 marks a crate. Routes from the top-left to the bottom-right, moving right or down.
func routesAvoiding(_ floor: [[Int]]) -> [[Int]] {
    let rows = floor.count, cols = floor[0].count
    var ways = Array(repeating: Array(repeating: 0, count: cols), count: rows)
    for r in 0..<rows {
        for c in 0..<cols {
            if floor[r][c] == 1 {
                ways[r][c] = 0                     // no route passes through a crate
            } else if r == 0 && c == 0 {
                ways[r][c] = 1                     // standing at the start is one route
            } else {
                let fromAbove = r > 0 ? ways[r - 1][c] : 0
                let fromLeft = c > 0 ? ways[r][c - 1] : 0
                ways[r][c] = fromAbove + fromLeft
            }
        }
    }
    return ways
}

let floor = [
    [0, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 0, 1],
    [1, 0, 0, 0],
]
for row in routesAvoiding(floor) {
    print(row)
}
