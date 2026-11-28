// Generated from src/dsa/content/lessons/dp-grids/dpg-min-path-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let grid = [
    [2, 3, 1, 4],
    [1, 7, 1, 2],
    [5, 2, 3, 1],
]
let rows = grid.count, cols = grid[0].count

// cost[r][c]: the cheapest total of any right/down path from the start to (r, c), both ends included
var cost = grid
for c in 1..<cols {
    cost[0][c] += cost[0][c - 1]                      // top row: only from the left
}
for r in 1..<rows {
    cost[r][0] += cost[r - 1][0]                      // left column: only from above
    for c in 1..<cols {
        cost[r][c] += min(cost[r - 1][c], cost[r][c - 1])
    }
}
for row in cost {
    print(row)
}

// Walk back from the goal, always to the neighbour the cell's cost came from
var (r, c) = (rows - 1, cols - 1)
var path = [grid[r][c]]
while r > 0 || c > 0 {
    if c == 0 || (r > 0 && cost[r - 1][c] <= cost[r][c - 1]) {
        r -= 1
    } else {
        c -= 1
    }
    path.append(grid[r][c])
}
print("cheapest:", cost[rows - 1][cols - 1], "via", Array(path.reversed()))
