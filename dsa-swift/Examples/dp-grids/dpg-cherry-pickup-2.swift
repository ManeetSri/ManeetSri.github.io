// Generated from src/dsa/content/lessons/dp-grids/dpg-cherry-pickup.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maxCherries(_ grid: [[Int]]) -> Int {
    let n = grid.count
    let impossible = Int.min / 2
    // best[r1][r2]: the most cherries after `step` moves each, with one walker in row r1 and the
    // other in row r2. Their columns are step - r1 and step - r2.
    var best = Array(repeating: Array(repeating: impossible, count: n), count: n)
    best[0][0] = grid[0][0]
    for step in stride(from: 1, through: 2 * n - 2, by: 1) {
        var next = Array(repeating: Array(repeating: impossible, count: n), count: n)
        let rowsOnDiagonal = max(0, step - (n - 1))...min(n - 1, step)
        for r1 in rowsOnDiagonal {
            for r2 in rowsOnDiagonal {
                let c1 = step - r1, c2 = step - r2
                if grid[r1][c1] == -1 || grid[r2][c2] == -1 {
                    continue                                   // a thorn bush: nobody stands here
                }
                // Each walker arrived from above (row - 1) or from the left (same row)
                var before = impossible
                for (a, b) in [(r1 - 1, r2 - 1), (r1 - 1, r2), (r1, r2 - 1), (r1, r2)] where a >= 0 && b >= 0 {
                    before = max(before, best[a][b])
                }
                if before == impossible {
                    continue
                }
                let picked = r1 == r2 ? grid[r1][c1] : grid[r1][c1] + grid[r2][c2]   // same cell: once
                next[r1][r2] = before + picked
            }
        }
        best = next
    }
    return max(0, best[n - 1][n - 1])
}

let orchard = [
    [1, 0, 1, 0, 0],
    [1, 0, 0, 0, 0],
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 1],
    [0, 1, 0, 0, 1],
]
print(maxCherries(orchard))
print(maxCherries([[1, 1, -1], [1, -1, 1], [0, 1, 1]]))
print(maxCherries([[1, -1], [-1, 1]]))
print(maxCherries([[1]]))
