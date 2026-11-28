// Generated from src/dsa/content/lessons/graph-basics/graph-implicit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let maze = [
    "..#.",
    ".##.",
    "....",
]
let cells = maze.map { Array($0) }
let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]     // up, down, left, right

// The edges of the implicit graph, worked out on demand
func neighbours(of row: Int, _ column: Int) -> [(Int, Int)] {
    var result: [(Int, Int)] = []
    for (dr, dc) in directions {
        let r = row + dr
        let c = column + dc
        guard r >= 0, r < cells.count, c >= 0, c < cells[r].count else { continue }  // off the grid
        guard cells[r][c] == "." else { continue }                                    // a wall
        result.append((r, c))
    }
    return result
}

print("(0, 0):", neighbours(of: 0, 0))
print("(2, 3):", neighbours(of: 2, 3))
print("(0, 1):", neighbours(of: 0, 1))

var openCells = 0
var degreeTotal = 0
for r in cells.indices {
    for c in cells[r].indices where cells[r][c] == "." {
        openCells += 1
        degreeTotal += neighbours(of: r, c).count
    }
}
print("vertices:", openCells, "edges:", degreeTotal / 2)
