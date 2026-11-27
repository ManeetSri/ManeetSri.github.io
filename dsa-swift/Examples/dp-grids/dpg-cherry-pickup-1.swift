// Generated from src/dsa/content/lessons/dp-grids/dpg-cherry-pickup.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let orchard = [
    [1, 0, 1, 0, 0],
    [1, 0, 0, 0, 0],
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 1],
    [0, 1, 0, 0, 1],
]

// The best single right/down walk, and the cells it uses (ties go right first)
func bestWalk(_ grid: [[Int]]) -> (cherries: Int, cells: [(Int, Int)]) {
    let n = grid.count
    var best = grid
    for r in 0..<n {
        for c in 0..<n where r > 0 || c > 0 {
            best[r][c] += max(r > 0 ? best[r - 1][c] : 0, c > 0 ? best[r][c - 1] : 0)
        }
    }
    var cells = [(n - 1, n - 1)]
    var (r, c) = (n - 1, n - 1)
    while r > 0 || c > 0 {
        if r == 0 || (c > 0 && best[r][c - 1] >= best[r - 1][c]) {
            c -= 1
        } else {
            r -= 1
        }
        cells.append((r, c))
    }
    return (best[n - 1][n - 1], cells)
}

var grid = orchard
let first = bestWalk(grid)
for (r, c) in first.cells {
    grid[r][c] = 0                       // the first walk picks these
}
let second = bestWalk(grid)
print("first walk:", first.cherries, "second walk:", second.cherries)
print("greedy total:", first.cherries + second.cherries)
print("cherries in the orchard:", orchard.joined().reduce(0, +))
