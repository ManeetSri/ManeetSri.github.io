// Generated from src/dsa/content/lessons/dp-grids/dpg-dungeon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minimumStartHealth(_ dungeon: [[Int]]) -> Int {
    let rows = dungeon.count, cols = dungeon[0].count
    let impossible = Int.max / 2
    // need[r][c]: the least health you can enter (r, c) with and still reach the goal alive.
    // An extra row and column of "impossible" saves bounds checks.
    var need = Array(repeating: Array(repeating: impossible, count: cols + 1), count: rows + 1)
    need[rows][cols - 1] = 1          // just past the goal you only need to be alive
    need[rows - 1][cols] = 1
    for r in stride(from: rows - 1, through: 0, by: -1) {
        for c in stride(from: cols - 1, through: 0, by: -1) {
            let onward = min(need[r + 1][c], need[r][c + 1])    // the easier way on
            need[r][c] = max(1, onward - dungeon[r][c])
        }
    }
    for row in need.dropLast() {
        print(row.dropLast().map(String.init).joined(separator: " "))
    }
    return need[0][0]
}

print("start with", minimumStartHealth([[0, -8, 20], [-1, -1, -1], [-1, -1, 0]]))
print("start with", minimumStartHealth([[-4, 3], [-2, -6]]))
