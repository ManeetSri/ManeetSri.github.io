// Generated from src/dsa/content/lessons/dp-grids/dpg-falling-path.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let slope = [
    [4, 1, 6, 3],
    [2, 8, 5, 7],
    [9, 3, 1, 4],
    [6, 2, 7, 5],
]

func cheapestFall(_ grid: [[Int]]) -> Int {
    let cols = grid[0].count
    var previous = grid[0]                     // a path that starts in row 0 costs just its first cell
    print(previous)
    for r in 1..<grid.count {
        var current = Array(repeating: 0, count: cols)
        for c in 0..<cols {
            let parents = max(0, c - 1)...min(cols - 1, c + 1)   // up to three cells above can reach (r, c)
            current[c] = grid[r][c] + previous[parents].min()!
        }
        previous = current
        print(previous)
    }
    return previous.min()!
}

print("cheapest fall:", cheapestFall(slope))
