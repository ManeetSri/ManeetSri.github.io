// Generated from src/dsa/content/lessons/dp-grids/dpg-dungeon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let dungeon = [
    [0, -8, 20],
    [-1, -1, -1],
    [-1, -1, 0],
]
let rows = dungeon.count, cols = dungeon[0].count

// Try every right/down path. For each, find its total and the health it needs at the start:
// enough that the running total never drops to 0 or below.
func explore(_ r: Int, _ c: Int, _ moves: String, _ total: Int, _ lowest: Int) {
    let total = total + dungeon[r][c]
    let lowest = min(lowest, total)
    if r == rows - 1 && c == cols - 1 {
        print(moves, "total", total, "needs", max(1, 1 - lowest))
        return
    }
    if c + 1 < cols {
        explore(r, c + 1, moves + "R", total, lowest)
    }
    if r + 1 < rows {
        explore(r + 1, c, moves + "D", total, lowest)
    }
}

explore(0, 0, "", 0, 0)
