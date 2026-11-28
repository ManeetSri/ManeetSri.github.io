// Generated from src/dsa/content/lessons/dp-grids/dpg-falling-path.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let slope = [
    [4, 1, 6, 3],
    [2, 8, 5, 7],
    [9, 3, 1, 4],
    [6, 2, 7, 5],
]

func twoRows(_ grid: [[Int]]) -> Int {
    let cols = grid[0].count
    var previous = grid[0]
    for r in 1..<grid.count {
        var current = Array(repeating: 0, count: cols)
        for c in 0..<cols {
            current[c] = grid[r][c] + previous[max(0, c - 1)...min(cols - 1, c + 1)].min()!
        }
        previous = current
    }
    return previous.min()!
}

func oneRowInPlace(_ grid: [[Int]]) -> Int {
    let cols = grid[0].count
    var best = grid[0]
    for r in 1..<grid.count {
        for c in 0..<cols {
            // Bug: best[c - 1] has already been overwritten with this row's value
            best[c] = grid[r][c] + best[max(0, c - 1)...min(cols - 1, c + 1)].min()!
        }
    }
    return best.min()!
}

print("two rows:", twoRows(slope))
print("one row, in place:", oneRowInPlace(slope))
